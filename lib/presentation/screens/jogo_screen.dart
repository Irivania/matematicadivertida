import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Importações de Camadas
import '../../../data/services/pergunta_service.dart';
import '../../../data/models/pergunta.dart';
import '../../../data/models/game_state.dart';
import '../controllers/game_controller.dart';
import '../../../core/theme/app_colors.dart';

// Widgets de Suporte
import '../widgets/dialogs/success_dialog.dart';
import '../widgets/dialogs/error_dialog.dart';

class JogoScreen extends StatefulWidget {
  final String perfil;

  const JogoScreen({
    super.key,
    required this.perfil,
  });

  @override
  State<JogoScreen> createState() => _JogoScreenState();
}

class _JogoScreenState extends State<JogoScreen> with WidgetsBindingObserver {
  // Instâncias de serviço e controle
  final _perguntaService = PerguntaService();
  late GameController _controller;

  // Estado Local da Tela
  Pergunta? _perguntaAtual;
  final _respostaController = TextEditingController();
  final _respostaFocusNode = FocusNode();
  final _geralFocusNode = FocusNode();

  Timer? _timer;
  int _tempoRestante = 60;
  bool _jogoAtivo = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = GameController(context: context);
    
    // Inicialização após o primeiro frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _iniciarDesafio());
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
    // Pausa o cronômetro se o usuário sair do app
    if (state == AppLifecycleState.paused && _jogoAtivo) {
      _pausarJogo();
    }
  }

  // --- Lógica de Negócio do Jogo ---

  void _iniciarDesafio() {
    if (!mounted) return;
    final gameState = context.read<GameState>();
    gameState.resetFase(); 
    
    setState(() {
      _jogoAtivo = true;
      _tempoRestante = 60;
    });

    _gerarPergunta();
    _iniciarCronometro();
    _gerenciarFocoAutomático();
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
      } else {
        setState(() => _tempoRestante--);
      }
    });
  }

  void _gerarPergunta() {
    final gameState = context.read<GameState>();
    
    final pergunta = _perguntaService.gerar(
      perfil: widget.perfil,
      nivel: gameState.nivelParaService,
      fase: gameState.faseAtual, 
    );

    setState(() {
      _perguntaAtual = pergunta;
      _respostaController.clear();
    });
    _gerenciarFocoAutomático();
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
    gameState.registrarAcerto();
    HapticFeedback.lightImpact(); // Feedback tátil (2026 UX)

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

    _exibirDialogo(ErrorDialog(
      mensagem: "🎮 Errado! A resposta era: $correta",
      onRetry: _iniciarDesafio,
    ));
  }

  void _finalizarPorTempo() {
    _cancelarTimer();
    setState(() => _jogoAtivo = false);
    
    _exibirDialogo(ErrorDialog(
      mensagem: "⌛ O tempo acabou!",
      onRetry: _iniciarDesafio,
    ));
  }

  void _concluirFase() {
    _cancelarTimer();
    setState(() => _jogoAtivo = false);
    
    final gameState = context.read<GameState>();
    
    _exibirDialogo(SuccessDialog(
      acertos: gameState.acertosNaFase,
      onNext: () {
        gameState.concluirEAvancarFase(); 
        _iniciarDesafio();
      },
    ));
  }

  // --- UI Helpers ---

  void _exibirDialogo(Widget dialog) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => dialog,
    );
  }

  void _gerenciarFocoAutomático() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      FocusScope.of(context).requestFocus(
        _jogoAtivo ? _respostaFocusNode : _geralFocusNode
      );
    });
  }

  void _exibirDicaDoCal() {
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
            child: const Text("ENTENDI", style: TextStyle(color: AppColors.neonCiano))
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final gameState = context.watch<GameState>();
    
    final bool ehCrianca = widget.perfil.toLowerCase().contains('crian');
    final double recuoTopo = ehCrianca ? screenHeight * 0.38 : screenHeight * 0.44;

    return KeyboardListener(
      focusNode: _geralFocusNode,
      autofocus: true,
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
            // Background Dinâmico
            Positioned.fill(
              child: Image.asset(
                _getImagemFundo(),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
            
            SafeArea(
              child: Column(
                children: [
                  SizedBox(height: recuoTopo),
                  _buildHUD(gameState),
                  const SizedBox(height: 12),
                  _buildProgressBar(gameState),
                  const Spacer(),
                  _buildMainContent(),
                  const Spacer(flex: 2),
                  _buildFooterButton(),
                  const SizedBox(height: 30),
                ],
              ),
            ),

            // Botão Voltar
            Positioned(
              top: 10, left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            if (_jogoAtivo) _buildMascoteCal(ehCrianca),
          ],
        ),
      ),
    );
  }

  // --- Widgets de Componentização ---

  Widget _buildHUD(GameState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonCiano.withValues(alpha: 0.3),
              blurRadius: 10
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatusItem(state.nomeNivelExibicao, "RANKING"),
            _buildStatusItem("${state.faseAtual}", "FASE"),
            _buildStatusItem("${state.indicePerguntaAtual}/${state.maxPerguntasPorFase}", "QUESTÃO"),
            _buildStatusItem("${_tempoRestante}s", "TEMPO", 
                color: _tempoRestante < 10 ? Colors.redAccent : Colors.blueAccent),
            _buildStatusItem("${state.xpTotal}", "PONTOS"),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String value, String label, {Color color = Colors.black87}) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.black45, fontSize: 8, fontWeight: FontWeight.w900)),
      ],
    );
  }

  Widget _buildProgressBar(GameState state) {
    final double progresso = state.indicePerguntaAtual / state.maxPerguntasPorFase;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: progresso.clamp(0.0, 1.0),
          minHeight: 8,
          backgroundColor: Colors.white24,
          color: Colors.greenAccent,
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (!_jogoAtivo) return const SizedBox.shrink();

    return Column(
      children: [
        Text(
          _perguntaAtual?.pergunta ?? "",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white, fontSize: 50, fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black, blurRadius: 15)],
          ),
        ),
        const SizedBox(height: 15),
        Container(
          width: 200,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.neonCiano, width: 4))
          ),
          child: TextField(
            controller: _respostaController,
            focusNode: _respostaFocusNode,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.text,
            style: const TextStyle(color: AppColors.neonCiano, fontSize: 50, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              border: InputBorder.none, 
              hintText: "?", 
              hintStyle: TextStyle(color: Colors.white24)
            ),
            onSubmitted: (_) => _validarResposta(),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: ElevatedButton(
        onPressed: _jogoAtivo ? _validarResposta : _iniciarDesafio,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonCiano,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(
          _jogoAtivo ? "CONFIRMAR" : "INICIAR DESAFIO",
          style: const TextStyle(
            color: AppColors.backgroundEscuro, 
            fontWeight: FontWeight.w900, 
            fontSize: 18
          ),
        ),
      ),
    );
  }

  Widget _buildMascoteCal(bool ehCrianca) {
    return Positioned(
      bottom: ehCrianca ? 130 : 100,
      right: 20,
      child: GestureDetector(
        onTap: _exibirDicaDoCal,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
              ),
              child: const Text("Dica?", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            ),
            const SizedBox(height: 4),
            SizedBox(width: 80, child: Image.asset('assets/images/mascote_cal.png')),
          ],
        ),
      ),
    );
  }

  String _getImagemFundo() {
    final p = widget.perfil.toLowerCase();
    if (p.contains('professor')) return 'assets/images/professor.png';
    if (p.contains('adulto')) return 'assets/images/adulto.png';
    return 'assets/images/crianca.png';
  }
}