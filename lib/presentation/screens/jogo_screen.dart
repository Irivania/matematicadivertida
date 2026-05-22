// lib/presentation/screens/jogo_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';

// Camadas de Dados e Domínio
import '../../../data/services/pergunta_service.dart';
import '../../../data/models/pergunta.dart';
import '../../../data/models/game_state.dart';
import '../../../core/theme/app_colors.dart';

// Controladores e Componentes Extraídos
import '../controllers/jogo_controller.dart';
import '../widgets/jogo/area_pergunta.dart';
import '../widgets/jogo/mascote_dica_widget.dart';

// Widgets de Interface (Diálogos)
import '../widgets/dialogs/error_dialog.dart';
import '../widgets/dialogs/fase_concluida_dialog.dart';

class JogoScreen extends StatefulWidget {
  final String perfil;
  final bool isModoDisputa; 

  const JogoScreen({
    super.key,
    required this.perfil,
    this.isModoDisputa = false, 
  });

  @override
  State<JogoScreen> createState() => _JogoScreenState();
}

class _JogoScreenState extends State<JogoScreen> with WidgetsBindingObserver {
  final _perguntaService = PerguntaService();

  // Gerenciamento de Estado Local
  Pergunta? _perguntaAtual;
  String _ultimaPerguntaProcessada = ""; 
  final _respostaController = TextEditingController();
  final _respostaFocusNode = FocusNode();
  final _geralFocusNode = FocusNode();

  Timer? _timer;
  int _tempoRestante = 60;
  bool _jogoAtivo = false;
  bool _disputaAtivaNaTela = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _disputaAtivaNaTela = widget.isModoDisputa || widget.perfil.toLowerCase().contains('disputa');
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _geralFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelarTimer();
    _respostaController.dispose();
    _respostaFocusNode.dispose();
    _geralFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && _jogoAtivo) _pausarJogo();
  }

  // --- Lógica de Acessibilidade (TTS) ---
  void _iniciarLeituraPergunta(Pergunta p) {
    final controller = context.read<JogoController>();
    controller.pararMicrofone();
    controller.falar(p.pergunta).then((_) {
      if (!kIsWeb && mounted && _jogoAtivo && context.read<GameState>().acessibilidadeVoz) {
        Future.delayed(const Duration(milliseconds: 1200), _acionarMicrofone);
      }
    });
  }

  void _acionarMicrofone() {
    if (!mounted || !_jogoAtivo) return;
    final gameState = context.read<GameState>();
    context.read<JogoController>().alternarMicrofone(
      onTextoCapturado: (textoReconhecido) {
        setState(() {
          _respostaController.text = gameState.normalizarRespostaFalada(textoReconhecido);
        });
      },
      onFinalizado: _validarResposta,
    );
  }

  // --- Lógica de Fluxo do Jogo ---

  void _iniciarDesafio() {
    if (!mounted) return;
    final gameState = context.read<GameState>();
    if (gameState.fase == 1 && _disputaAtivaNaTela) {
      gameState.resetTempoAcumulado(); 
    }
    
    gameState.resetFase(); 
    context.read<JogoController>().resetarTrava();
    
    setState(() {
      _jogoAtivo = true;
      _tempoRestante = 60;
      _ultimaPerguntaProcessada = ""; 
    });

    _gerarPergunta();
    _iniciarCronometro();
  }

  void _pausarJogo() {
    setState(() => _jogoAtivo = false);
    _cancelarTimer();
    context.read<JogoController>().pararMicrofone();
  }

  void _cancelarTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _iniciarCronometro() {
    _cancelarTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || !_jogoAtivo) return;
      if (_tempoRestante <= 0) {
        _finalizarPorTempo();
        return;
      }
      setState(() {
        _tempoRestante--; 
        if (_disputaAtivaNaTela) {
          context.read<GameState>().incrementarTempoGeral();
        }
      });
    });
  }

  void _gerarPergunta() {
    try {
      final gameState = context.read<GameState>();
      final pregunta = _perguntaService.gerar(
        perfil: widget.perfil,
        nivel: gameState.nivelParaService,
        fase: gameState.fase, 
      );

      if (pregunta.pergunta == _ultimaPerguntaProcessada) return;

      setState(() {
        _perguntaAtual = pregunta;
        _ultimaPerguntaProcessada = pregunta.pergunta;
        _respostaController.clear();
      });

      if (gameState.acessibilidadeVoz) {
        _iniciarLeituraPergunta(pregunta);
      }
      _garantirFoco();
    } catch (_) {}
  }

  void _validarResposta() {
    if (!_jogoAtivo || _perguntaAtual == null) return;
    final textoDigitado = _respostaController.text.trim().toLowerCase();
    final respostaCorreta = _perguntaAtual!.resposta.trim().toLowerCase();
    
    if (textoDigitado.isEmpty) return;
    if (textoDigitado != respostaCorreta) {
      _processarErro(respostaCorreta);
    } else {
      _processarAcerto();
    }
  }

  void _processarAcerto() {
    final gameState = context.read<GameState>();
    gameState.registrarAcerto(tempoRestante: _tempoRestante);
    HapticFeedback.mediumImpact();

    if (gameState.indicePerguntaAtual >= gameState.maxPerguntasPorFase) {
      _concluirFase();
    } else {
      gameState.avancarPergunta();
      _gerarPergunta(); 
    }
  }

  void _processarErro(String correta) {
    _cancelarTimer();
    context.read<JogoController>().pararMicrofone();
    SystemChannels.platform.invokeMethod('HapticFeedback.vibrate');
    setState(() => _jogoAtivo = false);
    final gameState = context.read<GameState>();

    if (gameState.acessibilidadeVoz) {
      context.read<JogoController>().falarFeedbackSistema(
          _disputaAtivaNaTela ? "Erro Fatal! A resposta era $correta" : "Você errou! A resposta era $correta"
      );
    }

    _exibirDialogo(
      _encapsularComTecladoDialog(
        ErrorDialog(
          // CORREÇÃO: Exibição da resposta correta inclusa
          mensagem: _disputaAtivaNaTela
              ? "🎯 Erro Fatal! No Modo Disputa você não pode errar. A resposta correta era: $correta. O desafio foi resetado!"
              : "🎮 A resposta correta era: $correta",
          onRetry: () {
            Navigator.pop(context);
            if (_disputaAtivaNaTela) gameState.recomecarNivelAtual();
            _iniciarDesafio();
          },
        ),
        onEnterPressed: () {
          Navigator.pop(context);
          if (_disputaAtivaNaTela) gameState.recomecarNivelAtual();
          _iniciarDesafio();
        },
      ),
    );
  }

  void _finalizarPorTempo() {
    _cancelarTimer();
    context.read<JogoController>().pararMicrofone();
    setState(() => _jogoAtivo = false);
    final gameState = context.read<GameState>();
    
    if (gameState.acessibilidadeVoz) {
      context.read<JogoController>().falarFeedbackSistema("O tempo esgotou!");
    }

    _exibirDialogo(
      _encapsularComTecladoDialog(
        ErrorDialog(
          mensagem: _disputaAtivaNaTela 
              ? "⌛ O tempo esgotou! No modo disputa, estourar 1 minuto causa reset total do Rank!"
              : "⌛ Seu tempo de 1 minuto acabou!",
          onRetry: () {
            Navigator.pop(context);
            if (_disputaAtivaNaTela) gameState.recomecarNivelAtual();
            _iniciarDesafio();
          },
        ),
        onEnterPressed: () {
          Navigator.pop(context);
          if (_disputaAtivaNaTela) gameState.recomecarNivelAtual();
          _iniciarDesafio();
        },
      ),
    );
  }

  Future<void> _concluirFase() async {
    _cancelarTimer();
    context.read<JogoController>().pararMicrofone();
    setState(() => _jogoAtivo = false);
    
    final gameState = context.read<GameState>();
    bool foiRecorde = false;
    bool nivelConcluido = gameState.fase == gameState.maxFasesPorNivel;

    if (_disputaAtivaNaTela && nivelConcluido) {
      foiRecorde = await gameState.verificarESalvarRecordeDoNivelCompleto(gameState.nivelAtual.name);
    }

    if (gameState.acessibilidadeVoz) {
      context.read<JogoController>().falarFeedbackSistema(
        nivelConcluido ? "Parabéns! Nível concluído com sucesso!" : "Fase concluída!"
      );
    }

    // Leitura direta do mapa no GameState
    int recordeSalvo = gameState.recordesPorNivel[gameState.nivelAtual.name.toLowerCase()] ?? 0;

    _exibirDialogo(
      _encapsularComTecladoDialog(
        FaseConcluidaDialog(
          titulo: nivelConcluido ? "🏆 NÍVEL ${gameState.nivel.toUpperCase()} CONCLUÍDO!" : "Fase ${gameState.fase} Concluída!",
          acertos: gameState.acertosNaFase,
          disputaAtiva: _disputaAtivaNaTela,
          nivelConcluido: nivelConcluido,
          tempoAtualSegundos: gameState.tempoAcumuladoNivel,
          recordeHistoricoSegundos: recordeSalvo,
          foiRecorde: foiRecorde,
          textoBotaoAvancar: nivelConcluido ? "PRÓXIMO NÍVEL" : "PRÓXIMA FASE",
          onRecomecar: () {
            Navigator.pop(context);
            gameState.recomecarNivelAtual();
            _iniciarDesafio();
          },
          onAvancar: () {
            Navigator.pop(context);
            gameState.concluirEAvancarFase();
            _iniciarDesafio();
          },
        ),
        onEnterPressed: () {
          Navigator.pop(context);
          gameState.concluirEAvancarFase();
          _iniciarDesafio();
        },
      ),
    );
  }

  // --- Auxiliares de UI ---

  void _garantirFoco() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _respostaFocusNode.requestFocus();
    });
  }

  void _exibirDialogo(Widget dialog) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => dialog,
    ).then((_) {
      if (mounted) _geralFocusNode.requestFocus();
    });
  }

  Widget _encapsularComTecladoDialog(Widget child, {required VoidCallback onEnterPressed}) {
    final FocusNode dialogFocus = FocusNode();
    dialogFocus.requestFocus();
    return KeyboardListener(
      focusNode: dialogFocus,
      onKeyEvent: (event) {
        if (event is KeyDownEvent && 
            (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
          dialogFocus.dispose();
          onEnterPressed();
        }
      },
      child: child,
    );
  }

  void _exibirDica() {
    if (_perguntaAtual == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundEscuro,
        title: const Text("Dica do Cal 🤖", style: TextStyle(color: AppColors.neonCiano)),
        content: Text(_perguntaAtual!.dica, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("OK", style: TextStyle(color: AppColors.neonCiano))
          )
        ],
      ),
    );
  }

  Widget _buildBotaoAcao() {
    final audioController = context.watch<JogoController>();
    final estaOuvindo = audioController.estaOuvindoMicrofone;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: ElevatedButton(
        onPressed: estaOuvindo ? _acionarMicrofone : (_jogoAtivo ? _validarResposta : _iniciarDesafio),
        style: ElevatedButton.styleFrom(
          backgroundColor: estaOuvindo ? Colors.redAccent : (_disputaAtivaNaTela ? Colors.greenAccent : AppColors.neonCiano), 
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          estaOuvindo ? "🎤 OUVINDO... CLIQUE PARA PARAR" : (_jogoAtivo ? "CONFIRMAR" : "COMEÇAR AGORA"),
          style: const TextStyle(color: AppColors.backgroundEscuro, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  String _getImagemFundo() {
    final p = widget.perfil.toLowerCase();
    if (p.contains('prof')) return 'assets/images/professor.png';
    if (p.contains('adul')) return 'assets/images/adulto.png';
    return 'assets/images/crianca.png';
  }

  Widget _buildHUD(GameState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _disputaAtivaNaTela ? Colors.black.withOpacity(0.8) : Colors.white.withAlpha(230), 
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(state.nivelAtual.icone, color: state.nivelAtual.cor, size: 18),
                  const SizedBox(width: 5),
                  Text(
                    state.nomeNivelExibicao.toUpperCase(), 
                    style: TextStyle(
                      color: _disputaAtivaNaTela ? Colors.white : Colors.black87, 
                      fontWeight: FontWeight.bold, 
                      fontSize: 16
                    ),
                  ),
                ],
              ),
              Text("RANK", style: TextStyle(fontSize: 10, color: _disputaAtivaNaTela ? Colors.white60 : Colors.grey)),
            ],
          ),
          _statusColumn("${state.fase}/10", "FASE"),
          _statusColumn("${state.indicePerguntaAtual}/${state.maxPerguntasPorFase}", "PERGUNTA"),
          if (_disputaAtivaNaTela)
            _statusColumn(state.formatarMinutos(state.tempoAcumuladoNivel), "TEMPO TOTAL", color: Colors.purpleAccent)
          else
            _statusColumn("${_tempoRestante}s", "RESTRANTE", color: _tempoRestante < 10 ? Colors.red : Colors.blue),
          _statusColumn("${state.pontos}", "XP"),
        ],
      ),
    );
  }

  Widget _statusColumn(String value, String label, {Color? color}) {
    final defaultColor = _disputaAtivaNaTela ? Colors.white : Colors.black87;
    return Column(
      children: [
        Text(value, style: TextStyle(color: color ?? defaultColor, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(fontSize: 10, color: _disputaAtivaNaTela ? Colors.white60 : Colors.grey)),
      ],
    );
  }

  Widget _buildProgressBar(GameState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: LinearProgressIndicator(
        value: state.maxPerguntasPorFase > 0 ? state.indicePerguntaAtual / state.maxPerguntasPorFase : 0,
        color: _disputaAtivaNaTela ? Colors.purpleAccent : Colors.greenAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final bool ehCrianca = widget.perfil.toLowerCase().contains('crian');

    return KeyboardListener(
      focusNode: _geralFocusNode,
      onKeyEvent: (event) {
        if (event is KeyDownEvent && 
            (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
          _jogoAtivo ? _validarResposta() : _iniciarDesafio();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Positioned.fill(child: Image.asset(_getImagemFundo(), fit: BoxFit.cover, alignment: Alignment.topCenter)),
            SafeArea(
              child: Column(
                children: [
                  SizedBox(height: ehCrianca ? 320 : 380),
                  _buildHUD(gameState),
                  const SizedBox(height: 12),
                  _buildProgressBar(gameState),
                  const Spacer(),
                  AreaPerguntaWidget(
                    perguntaAtual: _perguntaAtual,
                    jogoAtivo: _jogoAtivo,
                    disputaAtiva: _disputaAtivaNaTela,
                    controller: _respostaController,
                    focusNode: _respostaFocusNode,
                    onValidar: _validarResposta,
                  ),
                  const Spacer(flex: 2),
                  _buildBotaoAcao(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            if (_jogoAtivo && !_disputaAtivaNaTela) MascoteDicaWidget(perfil: widget.perfil, onExibirDica: _exibirDica),
            
            // Botão Sair
            Positioned(
              top: MediaQuery.of(context).padding.top + 15, 
              left: 15,
              child: InkWell(
                onTap: () {
                  _cancelarTimer();
                  context.read<JogoController>().pararMicrofone();
                  context.read<JogoController>().pararTTS();
                  FocusScope.of(context).unfocus();
                  Future.microtask(() { if (context.mounted) Navigator.of(context).pop(); });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75), 
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: _disputaAtivaNaTela ? Colors.purpleAccent : AppColors.neonCiano, width: 2),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 15),
                      SizedBox(width: 8),
                      Text("SAIR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    ],
                  ),
                ),
              ),
            ),

            // Botão Modo de Voz (Acessibilidade)
            Positioned(
              top: MediaQuery.of(context).padding.top + 15,
              right: 15,
              child: IconButton(
                icon: CircleAvatar(
                  backgroundColor: gameState.acessibilidadeVoz ? Colors.greenAccent : Colors.black87,
                  radius: 25,
                  child: Icon(
                    gameState.acessibilidadeVoz ? Icons.headset_mic : Icons.headset_off, 
                    color: gameState.acessibilidadeVoz ? Colors.black : Colors.white, 
                    size: 24
                  ),
                ),
                onPressed: () {
                  gameState.alternarAcessibilidadeVoz();
                  if (gameState.acessibilidadeVoz) {
                    context.read<JogoController>().resetarTrava();
                    _ultimaPerguntaProcessada = ""; 
                    if (_jogoAtivo && _perguntaAtual != null) {
                      _iniciarLeituraPergunta(_perguntaAtual!);
                    }
                  } else {
                    context.read<JogoController>().pararMicrofone();
                    context.read<JogoController>().pararTTS();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}