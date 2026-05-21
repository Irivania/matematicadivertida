// lib/presentation/screens/jogo_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

// Camadas de Dados e Domínio
import '../../../data/services/pergunta_service.dart';
import '../../../data/models/pergunta.dart';
import '../../../data/models/game_state.dart';
import '../../../core/theme/app_colors.dart';

// Widgets de Interface
import '../widgets/dialogs/success_dialog.dart';
import '../widgets/dialogs/error_dialog.dart';

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

  // Instâncias de Acessibilidade de Áudio
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();

  // Gerenciamento de Estado Local
  Pergunta? _perguntaAtual;
  final _respostaController = TextEditingController();
  final _respostaFocusNode = FocusNode();
  final _geralFocusNode = FocusNode();

  Timer? _timer;
  int _tempoRestante = 60; // 1 minuto limite por fase
  bool _jogoAtivo = false;
  bool _estaOuvindoMicrofone = false;

  // TRAVA DE SEGURANÇA: Guarda o texto da última pergunta lida para evitar duplicação por concorrência de estado
  String _ultimaPerguntaFalada = "";

  // Cronômetro progressivo que conta os segundos que o jogador levou para terminar a fase
  int _tempoAcumuladoDisputa = 0;
  
  // Flag local para garantir a detecção do modo de jogo de forma robusta
  bool _disputaAtivaNaTela = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initMotoresVoz();
    
    _disputaAtivaNaTela = widget.isModoDisputa || widget.perfil.toLowerCase().contains('disputa');
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _geralFocusNode.requestFocus();
      }
    });
  }

  /// Inicializa as configurações de fala e linguagem regional dos motores de áudio
  Future<void> _initMotoresVoz() async {
    try {
      await _flutterTts.setLanguage("pt-BR");
      await _flutterTts.setSpeechRate(0.55); // Velocidade de leitura confortável
      await _speech.initialize();
    } catch (_) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cancelarTimer();
    _flutterTts.stop();
    _speech.stop();
    _respostaController.dispose();
    _respostaFocusNode.dispose();
    _geralFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused && _jogoAtivo) {
      _pausarJogo();
    }
  }

  // --- Lógica de Fluxo do Jogo ---

  /// Executa o sintetizador de voz de forma blindada contra múltiplas chamadas simultâneas
  Future<void> _falarPerguntaAtual() async {
    if (_perguntaAtual == null) return;

    // Se o texto da pergunta for idêntico ao que acabou de ser falado, aborta a execução duplicada
    if (_ultimaPerguntaFalada == _perguntaAtual!.pergunta) {
      return; 
    }

    // Registra a pergunta atual na trava de segurança
    _ultimaPerguntaFalada = _perguntaAtual!.pergunta;

    await _flutterTts.stop();

    // Substitui sinais de operação por palavras para o motor pronunciar corretamente
    String textoParaFalar = _perguntaAtual!.pergunta
        .replaceAll('+', ' mais ')
        .replaceAll('-', ' menos ')
        .replaceAll('x', ' vezes ')
        .replaceAll('/', ' dividido por ');
        
    await _flutterTts.speak("Quanto é $textoParaFalar ?");
  }

  /// Ativa a captação do microfone por SpeechToText para ditar a resposta falada
  Future<void> _escutarRespostaVoz() async {
    final gameState = context.read<GameState>();
    if (!_estaOuvindoMicrofone) {
      bool disponivel = await _speech.initialize();
      if (disponivel) {
        setState(() => _estaOuvindoMicrofone = true);
        _speech.listen(
          onResult: (val) {
            setState(() {
              String processado = gameState.normalizarRespostaFalada(val.recognizedWords);
              _respostaController.text = processado;
            });
            // Se o motor finalizar e capturar um resultado estável, valida automaticamente
            if (val.finalResult) {
              setState(() => _estaOuvindoMicrofone = false);
              _validarResposta();
            }
          },
          localeId: "pt_BR",
        );
      }
    } else {
      setState(() => _estaOuvindoMicrofone = false);
      _speech.stop();
    }
  }

  void _iniciarDesafio() {
    if (!mounted) return;
    
    try {
      final gameState = context.read<GameState>();
      gameState.resetFase(); 
      
      setState(() {
        _jogoAtivo = true;
        _tempoRestante = 60;
        _tempoAcumuladoDisputa = 0;
        _ultimaPerguntaFalada = ""; // Reseta a trava ao iniciar uma nova partida
      });

      _gerarPergunta();
      _iniciarCronometro();

      // PROTEÇÃO WEB MANTIDA: Como o botão recebeu uma ação direta do usuário, 
      // o leitor de voz agora tem permissão do navegador para ler sem travar
      if (gameState.acessibilidadeVoz) {
        _falarPerguntaAtual().then((_) {
          Future.delayed(const Duration(milliseconds: 1800), () {
            if (mounted && _jogoAtivo && gameState.acessibilidadeVoz) _escutarRespostaVoz();
          });
        });
      }
    } catch (_) {
      setState(() {
        _jogoAtivo = false;
      });
    }
  }

  void _pausarJogo() {
    setState(() => _jogoAtivo = false);
    _cancelarTimer();
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
          _tempoAcumuladoDisputa++; 
        }
      });
    });
  }

  void _gerarPergunta() {
    try {
      final gameState = context.read<GameState>();
      
      final pergunta = _perguntaService.gerar(
        perfil: widget.perfil,
        nivel: gameState.nivelParaService,
        fase: gameState.fase, 
      );

      setState(() {
        _perguntaAtual = pergunta;
        _respostaController.clear();
      });

      // Se mudar de pergunta durante o jogo rodando com voz ativa
      if (gameState.acessibilidadeVoz && _ultimaPerguntaFalada != pergunta.pergunta && _respostaController.text.isEmpty) {
        _falarPerguntaAtual().then((_) {
          Future.delayed(const Duration(milliseconds: 1800), () {
            if (mounted && _jogoAtivo && gameState.acessibilidadeVoz) _escutarRespostaVoz();
          });
        });
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
    _speech.stop();
    _flutterTts.stop(); 
    setState(() {
      _jogoAtivo = false;
      _estaOuvindoMicrofone = false;
    });
    final gameState = context.read<GameState>();

    if (_disputaAtivaNaTela) {
      _exibirDialogo(
        _encapsularComTecladoDialog(
          ErrorDialog(
            mensagem: "🎯 Erro Fatal! No Modo Disputa você não pode errar. O desafio foi resetado para a Fase 1 deste Rank!",
            onRetry: () {
              Navigator.pop(context);
              gameState.recomecarNivelAtual(); 
              _iniciarDesafio();
            },
          ),
          onEnterPressed: () {
            Navigator.pop(context);
            gameState.recomecarNivelAtual();
            _iniciarDesafio();
          },
        ),
      );
    } else {
      gameState.registrarErro();
      _exibirDialogo(
        _encapsularComTecladoDialog(
          ErrorDialog(
            mensagem: "🎮 A resposta correta era: $correta",
            onRetry: () {
              Navigator.pop(context);
              _iniciarDesafio();
            },
          ),
          onEnterPressed: () {
            Navigator.pop(context);
            _iniciarDesafio();
          },
        ),
      );
    }
  }

  void _finalizarPorTempo() {
    _cancelarTimer();
    _speech.stop();
    _flutterTts.stop(); 
    setState(() {
      _jogoAtivo = false;
      _estaOuvindoMicrofone = false;
    });
    final gameState = context.read<GameState>();
    
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

  void _concluirFase() {
    _cancelarTimer();
    _speech.stop();
    _flutterTts.stop(); 
    setState(() {
      _jogoAtivo = false;
      _estaOuvindoMicrofone = false;
    });
    
    final gameState = context.read<GameState>();
    bool foiRecorde = false;
    bool nivelConcluido = false;

    if (_disputaAtivaNaTela) {
      gameState.acumularTempoDaFase(_tempoAcumuladoDisputa);
      if (gameState.fase == gameState.maxFasesPorNivel) {
        foiRecorde = gameState.verificarESalvarRecordeDoNivelCompleto(gameState.nivelAtual);
        nivelConcluido = true;
      }
    }

    String titulo = nivelConcluido 
        ? "🏆 NÍVEL ${gameState.nivel.toUpperCase()} CONCLUÍDO!" 
        : "Fase ${gameState.fase} Concluída!";

    _exibirDialogo(
      _encapsularComTecladoDialog(
        AlertDialog(
          backgroundColor: AppColors.backgroundEscuro,
          title: Text(titulo, style: const TextStyle(color: AppColors.neonCiano, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Você acertou ${gameState.acertosNaFase} questões!", style: const TextStyle(color: Colors.white)),
              if (_disputaAtivaNaTela) ...[
                const SizedBox(height: 10),
                Text("Tempo nesta fase: ${_tempoAcumuladoDisputa}s", style: const TextStyle(color: Colors.purpleAccent)),
                if (foiRecorde) ...[
                  const SizedBox(height: 10),
                  const Text("✨ PARABÉNS! NOVO RECORDE GLOBAL! ✨", style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 15)),
                ]
              ]
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                gameState.recomecarNivelAtual();
                _iniciarDesafio();
              },
              child: Text(
                nivelConcluido ? "RECORRER / MELHORAR TEMPO" : "RECOMEÇAR RANK DO ZERO", 
                style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                gameState.concluirEAvancarFase();
                _iniciarDesafio();
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonCiano),
              child: Text(nivelConcluido ? "PRÓXIMO NÍVEL" : "PRÓXIMA FASE", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
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
      if (mounted) {
        _geralFocusNode.requestFocus();
      }
    });
  }

  Widget _encapsularComTecladoDialog(Widget child, {required VoidCallback onEnterPressed}) {
    final FocusNode dialogFocus = FocusNode();
    dialogFocus.requestFocus();
    return KeyboardListener(
      focusNode: dialogFocus,
      onKeyEvent: (event) {
        if (event is KeyDownEvent && 
            (event.logicalKey == LogicalKeyboardKey.enter || 
             event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: ElevatedButton(
        onPressed: _estaOuvindoMicrofone ? _escutarRespostaVoz : (_jogoAtivo ? _validarResposta : _iniciarDesafio),
        style: ElevatedButton.styleFrom(
          backgroundColor: _estaOuvindoMicrofone 
              ? Colors.redAccent 
              : (_disputaAtivaNaTela ? Colors.greenAccent : AppColors.neonCiano), 
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: _disputaAtivaNaTela ? 8 : 4,
          shadowColor: _disputaAtivaNaTela ? Colors.greenAccent.withOpacity(0.5) : Colors.black38,
        ),
        child: Text(
          _estaOuvindoMicrofone 
              ? "🎤 OUVINDO... CLIQUE PARA PARAR" 
              : (_jogoAtivo ? "CONFIRMAR" : "COMEÇAR AGORA"),
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

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final bool ehCrianca = widget.perfil.toLowerCase().contains('crian');

    return KeyboardListener(
      focusNode: _geralFocusNode,
      onKeyEvent: (event) {
        if (event is KeyDownEvent && 
            (event.logicalKey == LogicalKeyboardKey.enter || 
             event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
          _jogoAtivo ? _validarResposta() : _iniciarDesafio();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // 1. Camada de Fundo
            Positioned.fill(
              child: Image.asset(
                _getImagemFundo(),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
            
            // 2. Camada de Conteúdo do Desafio
            SafeArea(
              child: Column(
                children: [
                  SizedBox(height: ehCrianca ? 320 : 380),
                  _buildHUD(gameState),
                  const SizedBox(height: 12),
                  _buildProgressBar(gameState),
                  const Spacer(),
                  _buildAreaDePergunta(),
                  const Spacer(flex: 2),
                  _buildBotaoAcao(),
                  const SizedBox(height: 30),
                ],
              ),
            ),

            // 3. Mascote de dicas
            if (_jogoAtivo && !_disputaAtivaNaTela) _buildMascoteDica(widget.perfil),
            
            // 4. Botão de Sair com proteção anti-travamento da Web
            Positioned(
              top: MediaQuery.of(context).padding.top + 15, 
              left: 15,
              child: InkWell(
                key: const ValueKey('btn_sair_game'),
                onTap: () {
                  _cancelarTimer();
                  _flutterTts.stop();
                  _speech.stop();
                  FocusScope.of(context).unfocus();
                  Future.microtask(() {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  });
                },
                borderRadius: BorderRadius.circular(30),
                child: Ink(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75), 
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: _disputaAtivaNaTela ? Colors.purpleAccent : AppColors.neonCiano, 
                      width: 2,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 15),
                      SizedBox(width: 8),
                      Text("SAIR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                    ],
                  ),
                ),
              ),
            ),

            // 5. Botão Flutuante Superior de Modo de Acessibilidade por Voz (Fone/Microfone)
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
                    _ultimaPerguntaFalada = ""; // Reseta o cache ao forçar o clique manual do botão
                    if (_jogoAtivo) {
                      _falarPerguntaAtual();
                    }
                  } else {
                    _flutterTts.stop();
                    _speech.stop();
                    setState(() {
                      _estaOuvindoMicrofone = false;
                      _ultimaPerguntaFalada = "";
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Componentes de Interface Adaptativos ---

  Widget _buildHUD(GameState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _disputaAtivaNaTela ? Colors.black.withOpacity(0.8) : Colors.white.withAlpha(230), 
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround, // CORREÇÃO: Sintaxe corrigida de 'Main => spaceAround' para 'MainAxisAlignment.spaceAround'
        children: [
          _statusColumn(state.nomeNivelExibicao, "RANK", textColor: _disputaAtivaNaTela ? Colors.white : Colors.black87),
          _statusColumn("${state.fase}/10", "FASE", textColor: _disputaAtivaNaTela ? Colors.white : Colors.black87),
          if (_disputaAtivaNaTela)
            _statusColumn("${_tempoAcumuladoDisputa}s", "TIME", color: Colors.purpleAccent, textColor: Colors.purpleAccent)
          else
            _statusColumn("${_tempoRestante}s", "RESTRANTE", color: _tempoRestante < 10 ? Colors.red : Colors.blue, textColor: _disputaAtivaNaTela ? Colors.white : Colors.black87),
          _statusColumn("${state.pontos}", "XP", textColor: _disputaAtivaNaTela ? Colors.white : Colors.black87),
        ],
      ),
    );
  }

  Widget _statusColumn(String value, String label, {Color color = Colors.transparent, Color textColor = Colors.black87}) {
    final effectiveColor = color == Colors.transparent ? textColor : color;
    return Column(
      children: [
        Text(value, style: TextStyle(color: effectiveColor, fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _buildAreaDePergunta() {
    if (!_jogoAtivo) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        margin: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: _disputaAtivaNaTela ? Colors.purpleAccent : AppColors.neonCiano, width: 1.5),
        ),
        child: Column(
          children: [
            Text(
              _disputaAtivaNaTela ? "🏁 MODO DISPUTA" : "🧠 MODO TREINO",
              style: TextStyle(color: _disputaAtivaNaTela ? Colors.purpleAccent : AppColors.neonCiano, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _disputaAtivaNaTela ? "Responda o mais rápido possível!\nErrar encerra o desafio." : "Treine suas habilidades matemáticas.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_disputaAtivaNaTela) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.purple.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
            child: const Text("VELOCIDADE MÁXIMA", style: TextStyle(color: Colors.purpleAccent, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 10),
        ],

        Text(
          _perguntaAtual?.pergunta ?? "",
          style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 180,
          child: TextField(
            controller: _respostaController,
            focusNode: _respostaFocusNode,
            textAlign: TextAlign.center,
            autofocus: true,
            keyboardType: TextInputType.number,
            style: TextStyle(color: _disputaAtivaNaTela ? Colors.purpleAccent : AppColors.neonCiano, fontSize: 48, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(hintText: "?", hintStyle: TextStyle(color: Colors.white24)),
            onSubmitted: (_) => _validarResposta(),
          ),
        ),
      ],
    );
  }

  Widget _buildMascoteDica(String perfil) {
    double bottomPos = perfil.toLowerCase().contains('crian') ? 130 : 150;
    return Positioned(
      bottom: bottomPos,
      right: 15, 
      child: GestureDetector(
        onTap: _exibirDica,
        child: Column(
          children: [
            const Text("DICA DO MASCOTE", style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.8), blurRadius: 10, spreadRadius: 2)]),
              child: Image.asset('assets/images/mascote_cal.png', width: 120, height: 120, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.smart_toy, size: 60, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}