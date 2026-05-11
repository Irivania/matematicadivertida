import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/pergunta_service.dart';
import '../models/pergunta.dart';
import '../controllers/game_controller.dart';

class JogoScreen extends StatefulWidget {
  final String perfil;

  const JogoScreen({
    super.key,
    required this.perfil,
  });

  @override
  State<JogoScreen> createState() => _JogoScreenState();
}

class _JogoScreenState extends State<JogoScreen>
    with SingleTickerProviderStateMixin {
  final service = PerguntaService();
  final controller = GameController();

  Pergunta? perguntaAtualObjeto;
  final respostaController = TextEditingController();
  final FocusNode respostaFocusNode = FocusNode();
  final FocusNode geralFocusNode = FocusNode();

  Timer? timer;
  int tempoRestante = 60;

  bool jogoAtivo = false;
  bool erroNaResposta = false;
  String mensagem = '';

  @override
  void initState() {
    super.initState();
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

  // =====================================================
  // GESTÃO DE FOCO
  // =====================================================
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

  // =====================================================
  // LÓGICA DE JOGO
  // =====================================================
  void iniciar() {
    controller.state.resetFase();
    setState(() {
      jogoAtivo = true;
      erroNaResposta = false;
      mensagem = '';
      tempoRestante = 60;
    });
    gerarPergunta();
    iniciarTimer();
    _gerenciarFoco();
  }

  void gerarPergunta() {
    final pergunta = service.gerar(
      perfil: widget.perfil,
      nivel: controller.getNomeNivel(),
      fase: controller.state.fase,
    );

    setState(() {
      perguntaAtualObjeto = pergunta;
      respostaController.clear();
      erroNaResposta = false;
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
    setState(() {
      jogoAtivo = false;
      erroNaResposta = true;
      mensagem = "⌛ O tempo acabou!\n\nVocê perdeu essa batalha matemática… mas heróis nunca desistem!";
    });
    _gerenciarFoco();
  }

  void responder() {
    if (!jogoAtivo) return;
    if (perguntaAtualObjeto == null) return;

    final textoDigitado = respostaController.text.trim();

    if (textoDigitado.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Digite uma resposta primeiro!"),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    final String respostaUsuario = textoDigitado.toLowerCase();
    final String respostaCorreta = perguntaAtualObjeto!.resposta.trim().toLowerCase();
    final bool correto = respostaUsuario == respostaCorreta;

    if (!correto) {
      timer?.cancel();
      controller.responder(false, widget.perfil);

      setState(() {
        jogoAtivo = false;
        erroNaResposta = true;
        mensagem = "🎮⚡ Você perdeu essa batalha matemática… mas heróis nunca desistem!\n\n"
                   "💎 A resposta correta era: ${perguntaAtualObjeto!.resposta}";
      });
      _gerenciarFoco();
      return;
    }

    final resultado = controller.responder(true, widget.perfil);
    if (resultado == ResultadoResposta.faseCompleta) {
      timer?.cancel();
      setState(() {
        jogoAtivo = false;
        erroNaResposta = false;
        mensagem = "🏆 Nível concluído!\n\nVocê é um verdadeiro mestre da matemática!";
      });
      controller.proximaFase();
    } else {
      gerarPergunta();
    }
    _gerenciarFoco();
  }

  // =====================================================
  // AJUDA DO CAL (AJUSTADO COM ENTER PARA SAIR)
  // =====================================================
  void _exibirAjudaDoCal() {
    if (perguntaAtualObjeto == null) return;

    showDialog(
      context: context,
      builder: (context) {
        final FocusNode dialogFocusNode = FocusNode();
        
        return KeyboardListener(
          focusNode: dialogFocusNode,
          autofocus: true,
          onKeyEvent: (event) {
            if (event is KeyDownEvent &&
                (event.logicalKey == LogicalKeyboardKey.enter ||
                 event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
              Navigator.pop(context);
            }
          },
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xEE1A1A1A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.cyanAccent, width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Dica do Cal",
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    perguntaAtualObjeto!.dica,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                    child: const Text(
                      "ENTENDI! [ENTER]",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // =====================================================
  // INTERFACE (BUILD)
  // =====================================================
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final perfil = widget.perfil.toLowerCase().trim();
    final bool ehCrianca = perfil == 'criança' || perfil == 'crianca';
    final double recuoTopo = perfil == 'adulto' ? screenHeight * 0.44 : screenHeight * 0.38;

    return KeyboardListener(
      focusNode: geralFocusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.enter ||
             event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
          if (!jogoAtivo) {
            iniciar();
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
                  _buildHUD(),
                  const SizedBox(height: 12),
                  _buildProgressBar(),
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

  Widget _buildMascoteCal(bool ehCrianca) {
    return Positioned(
      bottom: ehCrianca ? 130 : 100,
      right: ehCrianca ? 10 : 20,
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
            SizedBox(width: 85, child: Image.asset('assets/images/mascote_cal.png')),
          ],
        ),
      ),
    );
  }

  Widget _buildHUD() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatusItem(controller.getNomeNivelFormatado(), "NÍVEL"),
            _buildStatusItem("${controller.state.fase}", "FASE"),
            _buildStatusItem("${controller.state.perguntaAtual + 1}/${controller.state.perguntasPorFase}", "QUESTÃO"),
            _buildStatusItem("${tempoRestante}s", "TEMPO", 
                color: tempoRestante < 10 ? Colors.redAccent : Colors.blueAccent),
            _buildStatusItem("${controller.state.pontos}", "PONTOS"),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String value, String label, {Color color = Colors.black87}) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.black45, fontSize: 8, letterSpacing: 1.1)),
      ],
    );
  }

  Widget _buildProgressBar() {
    final progresso = controller.state.perguntaAtual / controller.state.perguntasPorFase;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: progresso.clamp(0.0, 1.0),
          minHeight: 4,
          backgroundColor: Colors.white24,
          color: Colors.greenAccent,
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (!jogoAtivo) {
      return Container(
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              erroNaResposta ? Icons.highlight_off_rounded : Icons.stars_rounded,
              color: erroNaResposta ? Colors.red : Colors.green,
              size: 55,
            ),
            const SizedBox(height: 10),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            const Text("[ ENTER PARA CONTINUAR ]", style: TextStyle(fontSize: 10, color: Colors.black38)),
          ],
        ),
      );
    }

    return Column(
      children: [
        Text(
          perguntaAtualObjeto?.pergunta ?? "",
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white, fontSize: 46, fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black, blurRadius: 12)],
          ),
        ),
        const SizedBox(height: 15),
        Container(
          width: 180,
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.orangeAccent, width: 3))),
          child: TextField(
            controller: respostaController,
            focusNode: respostaFocusNode,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            style: const TextStyle(color: Colors.orangeAccent, fontSize: 50, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(border: InputBorder.none),
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
          backgroundColor: jogoAtivo ? Colors.orange : (erroNaResposta ? Colors.red : Colors.green),
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(
          jogoAtivo ? "CONFIRMAR" : "TENTAR DE NOVO",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  String _getImagemFundo() {
    final perfil = widget.perfil.toLowerCase().trim();
    if (perfil == 'professor') return 'assets/images/professor.png';
    if (perfil == 'adulto') return 'assets/images/adulto.png';
    return 'assets/images/crianca.png';
  }
}