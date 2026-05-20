// lib/presentation/screens/jogo_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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

  // Gerenciamento de Estado Local
  Pergunta? _perguntaAtual;
  final _respostaController = TextEditingController();
  final _respostaFocusNode = FocusNode();
  final _geralFocusNode = FocusNode();

  Timer? _timer;
  int _tempoRestante = 60; // 1 minuto limite por fase
  bool _jogoAtivo = false;

  // Cronômetro progressivo que conta os segundos que o jogador levou para terminar a fase
  int _tempoAcumuladoDisputa = 0;
  
  // Flag local para garantir a detecção do modo de jogo de forma robusta
  bool _disputaAtivaNaTela = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // CORREÇÃO MANTIDA: Acumula a flag vinda do construtor ou do texto do perfil de forma segura
    _disputaAtivaNaTela = widget.isModoDisputa || widget.perfil.toLowerCase().contains('disputa');
    
    // CORREÇÃO MANTIDA: O jogo aguarda o clique inicial no botão para começar. Preparamos o foco do teclado.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _geralFocusNode.requestFocus();
      }
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
    if (state == AppLifecycleState.paused && _jogoAtivo) {
      _pausarJogo();
    }
  }

  // --- Lógica de Fluxo do Jogo ---

  void _iniciarDesafio() {
    if (!mounted) return;
    
    try {
      final gameState = context.read<GameState>();
      
      // Reseta o progresso da fase atual ao iniciar/reiniciar
      gameState.resetFase(); 
      
      setState(() {
        _jogoAtivo = true;
        _tempoRestante = 60; // Garante 1 minuto regulamentar no início da fase
        _tempoAcumuladoDisputa = 0; // Reseta o cronômetro progressivo da disputa
      });

      _gerarPergunta();
      _iniciarCronometro();
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
      
      // Se o tempo da fase acabar (1 minuto), ambos os modos sofrem Game Over
      if (_tempoRestante <= 0) {
        _finalizarPorTempo();
        return;
      }

      setState(() {
        _tempoRestante--; // Ambos os modos decrementam o limite de 1 minuto da fase
        
        if (_disputaAtivaNaTela) {
          _tempoAcumuladoDisputa++; // A disputa monitora o tempo progressivo gasto
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
    
    // Passa o tempo restante para cálculo de XP no modo treino
    gameState.registrarAcerto(tempoRestante: _tempoRestante);
    HapticFeedback.mediumImpact();

    // Se respondeu as 10 perguntas da fase, conclui
    if (gameState.indicePerguntaAtual >= gameState.maxPerguntasPorFase) {
      _concluirFase();
    } else {
      gameState.avancarPergunta();
      _gerarPergunta();
    }
  }

  void _processarErro(String correta) {
    _cancelarTimer();
    setState(() => _jogoAtivo = false);

    final gameState = context.read<GameState>();

    if (_disputaAtivaNaTela) {
      // Regra da Disputa: Errou 1 única vez = Erro fatal e fim de jogo imediato!
      _exibirDialogo(
        _encapsularComTecladoDialog(
          ErrorDialog(
            mensagem: "🎯 Erro Fatal! No Modo Disputa você não pode errar nenhuma resposta. Tente novamente!",
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
    } else {
      // Modo Treino: Desconta uma vida no GameState e permite continuar se ainda tiver vidas
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
    setState(() => _jogoAtivo = false);
    
    _exibirDialogo(
      _encapsularComTecladoDialog(
        ErrorDialog(
          mensagem: _disputaAtivaNaTela 
              ? "⌛ O tempo de 1 minuto esgotou! Você precisa ser mais rápido no Modo Disputa."
              : "⌛ Seu tempo de 1 minuto acabou!",
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

  void _concluirFase() {
    _cancelarTimer();
    setState(() => _jogoAtivo = false);
    
    final gameState = context.read<GameState>();
    bool foiRecorde = false;

    if (_disputaAtivaNaTela) {
      // Grava o tempo que ele levou para terminar e verifica se quebrou o recorde do nível
      foiRecorde = gameState.verificarESalvarRecordeDesteNivel(
        gameState.nivelAtual, 
        _tempoAcumuladoDisputa,
      );
    }

    _exibirDialogo(
      _encapsularComTecladoDialog(
        SuccessDialog(
          acertos: gameState.acertosNaFase,
          // Passa o tempo progressivo gasto apenas se for Modo Disputa
          tempoGasto: _disputaAtivaNaTela ? Duration(seconds: _tempoAcumuladoDisputa) : null,
          isRecordePessoal: foiRecorde, 
          onNext: () {
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
      // Garante o retorno do foco do teclado principal ao fechar qualquer pop-up
      if (mounted) {
        _geralFocusNode.requestFocus();
      }
    });
  }

  /// Método utilitário auxiliar para capturar o clique do Enter de forma isolada 
  /// sobre os pop-ups nativos do Flutter sem precisar modificar os arquivos internos dos Diálogos.
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

  // CORREÇÃO: Botão de ação inferior robusto com tons Verdes no modo disputa
  Widget _buildBotaoAcao() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: ElevatedButton(
        onPressed: _jogoAtivo ? _validarResposta : _iniciarDesafio,
        style: ElevatedButton.styleFrom(
          backgroundColor: _disputaAtivaNaTela ? Colors.greenAccent : AppColors.neonCiano, // Rosa alterado para Verde no modo disputa
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: _disputaAtivaNaTela ? 8 : 4,
          shadowColor: _disputaAtivaNaTela ? Colors.greenAccent.withOpacity(0.5) : Colors.black38,
        ),
        child: Text(
          _jogoAtivo ? "CONFIRMAR" : "COMEÇAR AGORA",
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

            // 3. Mascote de dicas (Ocultado se for modo disputa)
            if (_jogoAtivo && !_disputaAtivaNaTela) _buildMascoteDica(ehCrianca),
            
            // 4. CORREÇÃO MANTIDA: Botão de Sair em pílula com proteção anti-travamento da Web (Future.microtask)
            Positioned(
              top: MediaQuery.of(context).padding.top + 15, 
              left: 15,
              child: InkWell(
                key: const ValueKey('btn_sair_game'),
                onTap: () {
                  _cancelarTimer();
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
                    boxShadow: [
                      BoxShadow(
                        color: (_disputaAtivaNaTela ? Colors.purpleAccent : AppColors.neonCiano).withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back_ios_new, 
                        color: Colors.white, 
                        size: 15,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "SAIR",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Componentes de Interface Adaptativos ---

  // CORREÇÃO MANTIDA: HUD escuro/roxo na disputa e claro/azul no treino
  Widget _buildHUD(GameState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _disputaAtivaNaTela 
            ? Colors.black.withOpacity(0.8) 
            : Colors.white.withAlpha((0.9 * 255).toInt()), 
        borderRadius: BorderRadius.circular(15),
        border: _disputaAtivaNaTela 
            ? Border.all(color: Colors.purpleAccent, width: 1.5) 
            : null,
        boxShadow: [
          BoxShadow(
            color: _disputaAtivaNaTela ? Colors.purpleAccent.withOpacity(0.3) : Colors.black26, 
            blurRadius: 8
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statusColumn(
            state.nomeNivelExibicao, 
            "RANK",
            textColor: _disputaAtivaNaTela ? Colors.white : Colors.black87
          ),
          _statusColumn(
            "${state.fase}/10", 
            "FASE",
            textColor: _disputaAtivaNaTela ? Colors.white : Colors.black87
          ),
          
          if (_disputaAtivaNaTela)
            _statusColumn(
              "${_tempoAcumuladoDisputa}s", 
              "CRONÔMETRO", 
              color: Colors.purpleAccent,
              textColor: Colors.purpleAccent
            )
          else
            _statusColumn(
              "${_tempoRestante}s", 
              "RESTRANTE", 
              color: _tempoRestante < 10 ? Colors.red : Colors.blue,
              textColor: _disputaAtivaNaTela ? Colors.white : Colors.black87
            ),
            
          _statusColumn(
            "${state.pontos}", 
            "XP",
            textColor: _disputaAtivaNaTela ? Colors.white : Colors.black87
          ),
        ],
      ),
    );
  }

  // CORREÇÃO MANTIDA: Parâmetro do TextStyle ajustado para 'color' corrigindo o erro de compilação
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
        backgroundColor: _disputaAtivaNaTela ? Colors.white12 : Colors.white24,
        color: _disputaAtivaNaTela ? Colors.purpleAccent : Colors.greenAccent,
        minHeight: 6,
      ),
    );
  }

  // CORREÇÃO MANTIDA: Estado de boas-vindas com títulos e cores separados e aviso "VELOCIDADE MÁXIMA"
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
              style: TextStyle(
                color: _disputaAtivaNaTela ? Colors.purpleAccent : AppColors.neonCiano,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _disputaAtivaNaTela 
                ? "Responda o mais rápido possível!\nErrar encerra o desafio."
                : "Treine suas habilidades matemáticas sem a pressão do ranking.",
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
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purpleAccent, width: 1),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.flash_on, color: Colors.purpleAccent, size: 14),
                SizedBox(width: 4),
                Text(
                  "VELOCIDADE MÁXIMA",
                  style: TextStyle(color: Colors.purpleAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],

        Text(
          _perguntaAtual?.pergunta ?? "",
          style: TextStyle(
            color: Colors.white, 
            fontSize: 56, 
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: _disputaAtivaNaTela ? Colors.purple : Colors.black, 
                blurRadius: 15
              )
            ],
          ),
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
            style: TextStyle(
              color: _disputaAtivaNaTela ? Colors.purpleAccent : AppColors.neonCiano, 
              fontSize: 48, 
              fontWeight: FontWeight.bold
            ),
            decoration: InputDecoration(
              hintText: "?",
              hintStyle: const TextStyle(color: Colors.white24),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: _disputaAtivaNaTela ? Colors.purpleAccent : AppColors.neonCiano, 
                  width: 3
                )
              ),
            ),
            onSubmitted: (_) => _validarResposta(),
          ),
        ),
      ],
    );
  }

  Widget _buildMascoteDica(bool ehCrianca) {
    return Positioned(
      bottom: ehCrianca ? 140 : 110,
      right: 20,
      child: GestureDetector(
        onTap: _exibirDica,
        child: Column(
          children: [
            const Text("DICA", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            Image.asset('assets/images/mascote_cal.png', width: 70),
          ],
        ),
      ),
    );
  }
}