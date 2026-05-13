import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../data/services/pergunta_service.dart';
import '../../../data/models/pergunta.dart';
import '../../../data/models/game_state.dart';
import '../controllers/game_controller.dart';
import '../../../core/theme/app_colors.dart';
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

class _JogoScreenState extends State<JogoScreen> {
  final service = PerguntaService();
  late GameController controller;

  Pergunta? perguntaAtualObjeto;
  final respostaController = TextEditingController();
  final FocusNode respostaFocusNode = FocusNode();
  final FocusNode geralFocusNode = FocusNode();

  Timer? timer;
  int tempoRestante = 60;

  bool jogoAtivo = false;

  @override
  void initState() {
    super.initState();
    controller = GameController(context: context);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      iniciar();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    respostaController.dispose();
    respostaFocusNode.dispose();
    geralFocusNode.dispose();
    super.dispose();
  }

  void _gerenciarFoco() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      if (jogoAtivo) {
        FocusScope.of(context).requestFocus(respostaFocusNode);
      } else {
        FocusScope.of(context).requestFocus(geralFocusNode);
      }
    });
  }

  void iniciar() {
    final gameState = Provider.of<GameState>(context, listen: false);
    gameState.resetFase(); 
    
    setState(() {
      jogoAtivo = true;
      tempoRestante = 60;
    });
    gerarPergunta();
    iniciarTimer();
    _gerenciarFoco();
  }

  void gerarPergunta() {
    final gameState = Provider.of<GameState>(context, listen: false);
    
    // CORREÇÃO: fase -> faseAtual
    final pergunta = service.gerar(
      perfil: widget.perfil,
      nivel: gameState.nivelParaService,
      fase: gameState.faseAtual, 
    );

    setState(() {
      perguntaAtualObjeto = pergunta;
      respostaController.clear();
    });
    _gerenciarFoco();
  }

  void iniciarTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || !jogoAtivo) return;
      if (tempoRestante <= 0) {
        _pararPorTempo();
      } else {
        setState(() => tempoRestante--);
      }
    });
  }

  void _pararPorTempo() {
    timer?.cancel();
    setState(() => jogoAtivo = false);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ErrorDialog(
        mensagem: "⌛ O tempo acabou!",
        onRetry: iniciar,
      ),
    );
  }

  void responder() {
    if (!jogoAtivo || perguntaAtualObjeto == null) return;

    final textoDigitado = respostaController.text.trim();
    if (textoDigitado.isEmpty) return;

    final String respostaUsuario = textoDigitado.toLowerCase();
    final String respostaCorreta = perguntaAtualObjeto!.resposta.trim().toLowerCase();
    
    if (respostaUsuario != respostaCorreta) {
      timer?.cancel();
      setState(() => jogoAtivo = false);

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => ErrorDialog(
          mensagem: "🎮 Errado! A resposta era: ${perguntaAtualObjeto!.resposta}",
          onRetry: iniciar,
        ),
      );
      return;
    }

    final gameState = Provider.of<GameState>(context, listen: false);
    gameState.registrarAcerto();

    // CORREÇÃO: perguntaAtual -> indicePerguntaAtual
    if (gameState.indicePerguntaAtual >= gameState.maxPerguntasPorFase) {
      _finalizarFase();
    } else {
      gameState.avancarPergunta();
      gerarPergunta();
    }
  }

  void _finalizarFase() {
    timer?.cancel();
    setState(() => jogoAtivo = false);
    
    final gameState = Provider.of<GameState>(context, listen: false);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SuccessDialog(
        acertos: gameState.acertosNaFase,
        onNext: () {
          gameState.concluirEAvancarFase(); 
          iniciar();
        },
      ),
    );
  }

  void _exibirAjudaDoCal() {
    if (perguntaAtualObjeto == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundEscuro,
        title: const Text("Dica do Cal 🤖", style: TextStyle(color: AppColors.neonCiano)),
        content: Text(perguntaAtualObjeto!.dica, style: const TextStyle(color: Colors.white)),
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
      focusNode: geralFocusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.enter ||
             event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
          if (!jogoAtivo) {
            iniciar();
          } else {
            responder();
          }
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
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

            Positioned(
              top: 10, left: 10,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            if (jogoAtivo) _buildMascoteCal(ehCrianca),
          ],
        ),
      ),
    );
  }

  Widget _buildHUD(GameState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9), 
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonCiano.withOpacity(0.3), 
              blurRadius: 10
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatusItem(state.nomeNivelExibicao, "RANKING"),
            // CORREÇÃO: fase -> faseAtual
            _buildStatusItem("${state.faseAtual}", "FASE"),
            // CORREÇÃO: perguntaAtual -> indicePerguntaAtual
            _buildStatusItem("${state.indicePerguntaAtual}/${state.maxPerguntasPorFase}", "QUESTÃO"),
            _buildStatusItem("${tempoRestante}s", "TEMPO", 
                color: tempoRestante < 10 ? Colors.redAccent : Colors.blueAccent),
            // CORREÇÃO: pontosTotal -> xpTotal
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
    // CORREÇÃO: perguntaAtual -> indicePerguntaAtual
    final progresso = state.indicePerguntaAtual / state.maxPerguntasPorFase;
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
    if (!jogoAtivo) return const SizedBox.shrink();

    return Column(
      children: [
        Text(
          perguntaAtualObjeto?.pergunta ?? "",
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
            controller: respostaController,
            focusNode: respostaFocusNode,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.text,
            style: const TextStyle(color: AppColors.neonCiano, fontSize: 50, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              border: InputBorder.none, 
              hintText: "?", 
              hintStyle: TextStyle(color: Colors.white24)
            ),
            onSubmitted: (_) => responder(),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: ElevatedButton(
        onPressed: jogoAtivo ? responder : iniciar,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.neonCiano,
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(
          jogoAtivo ? "CONFIRMAR" : "INICIAR DESAFIO",
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
        onTap: _exibirAjudaDoCal,
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