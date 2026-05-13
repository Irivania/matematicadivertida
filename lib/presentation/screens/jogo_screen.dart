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

  const JogoScreen({
    super.key,
    required this.perfil,
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
  int _tempoRestante = 60;
  bool _jogoAtivo = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Inicializa o estado do jogo após o carregamento da tela
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
    if (state == AppLifecycleState.paused && _jogoAtivo) {
      _pausarJogo();
    }
  }

  // --- Lógica de Fluxo do Jogo ---

  void _iniciarDesafio() {
    if (!mounted) return;
    final gameState = context.read<GameState>();
    
    // Reseta o progresso para uma nova rodada
    gameState.resetFase(); 
    
    setState(() {
      _jogoAtivo = true;
      _tempoRestante = 60;
    });

    _gerarPergunta();
    _iniciarCronometro();
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
      fase: gameState.fase, 
    );

    setState(() {
      _perguntaAtual = pergunta;
      _respostaController.clear();
    });
    
    _garantirFoco();
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
    HapticFeedback.mediumImpact();

    // Verifica se completou a quantidade de questões da fase
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
      mensagem: "🎮 A resposta correta era: $correta",
      onRetry: () {
        Navigator.pop(context);
        _iniciarDesafio();
      },
    ));
  }

  void _finalizarPorTempo() {
    _cancelarTimer();
    setState(() => _jogoAtivo = false);
    
    _exibirDialogo(ErrorDialog(
      mensagem: "⌛ Seu tempo acabou!",
      onRetry: () {
        Navigator.pop(context);
        _iniciarDesafio();
      },
    ));
  }

  void _concluirFase() {
    _cancelarTimer();
    setState(() => _jogoAtivo = false);
    
    final gameState = context.read<GameState>();
    
    _exibirDialogo(SuccessDialog(
      acertos: gameState.acertosNaFase,
      onNext: () {
        Navigator.pop(context);
        gameState.concluirEAvancarFase(); 
        _iniciarDesafio();
      },
    ));
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
            // Background Adaptativo
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

            if (_jogoAtivo) _buildMascoteDica(ehCrianca),
            
            // Voltar
            Positioned(
              top: 10, left: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Componentes de Interface ---

  Widget _buildHUD(GameState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statusColumn(state.nomeNivelExibicao, "RANK"),
          _statusColumn("${state.fase}", "FASE"),
          _statusColumn("${_tempoRestante}s", "TEMPO", 
            color: _tempoRestante < 10 ? Colors.red : Colors.blue),
          _statusColumn("${state.pontos}", "XP"),
        ],
      ),
    );
  }

  Widget _statusColumn(String value, String label, {Color color = Colors.black87}) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildProgressBar(GameState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: LinearProgressIndicator(
        value: state.indicePerguntaAtual / state.maxPerguntasPorFase,
        backgroundColor: Colors.white24,
        color: Colors.greenAccent,
        minHeight: 6,
      ),
    );
  }

  Widget _buildAreaDePergunta() {
    if (!_jogoAtivo) return const SizedBox.shrink();

    return Column(
      children: [
        Text(
          _perguntaAtual?.pergunta ?? "",
          style: const TextStyle(
            color: Colors.white, fontSize: 56, fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black, blurRadius: 10)],
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
            style: const TextStyle(color: AppColors.neonCiano, fontSize: 48, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              hintText: "?",
              hintStyle: TextStyle(color: Colors.white24),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.neonCiano, width: 3)),
            ),
            onSubmitted: (_) => _validarResposta(),
          ),
        ),
      ],
    );
  }

  Widget _buildBotaoAcao() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: ElevatedButton(
        onPressed: _jogoAtivo ? _validarResposta : _iniciarDesafio,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonCiano,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          _jogoAtivo ? "CONFIRMAR" : "COMEÇAR AGORA",
          style: const TextStyle(color: AppColors.backgroundEscuro, fontWeight: FontWeight.bold),
        ),
      ),
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

  String _getImagemFundo() {
    final p = widget.perfil.toLowerCase();
    if (p.contains('prof')) return 'assets/images/professor.png';
    if (p.contains('adul')) return 'assets/images/adulto.png';
    return 'assets/images/crianca.png';
  }
}