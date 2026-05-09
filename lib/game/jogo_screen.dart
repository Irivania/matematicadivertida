import 'dart:async';
import 'package:flutter/material.dart';
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

  Pergunta? perguntaAtual;

  final respostaController = TextEditingController();

  final FocusNode respostaFocusNode = FocusNode();

  Timer? timer;

  int tempoRestante = 60;

  bool jogoAtivo = false;

  String mensagem = '';

  late AnimationController _pulseController;

  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // 🔥 INICIA AUTOMATICAMENTE
    WidgetsBinding.instance.addPostFrameCallback((_) {
      iniciar();
    });
  }

  @override
  void dispose() {
    timer?.cancel();

    respostaController.dispose();

    respostaFocusNode.dispose();

    _pulseController.dispose();

    super.dispose();
  }

  // =========================================================
  // FOCO
  // =========================================================

  void _garantirFoco() {
    if (mounted) {
      FocusScope.of(context).requestFocus(respostaFocusNode);
    }
  }

  // =========================================================
  // IMAGEM DE FUNDO
  // =========================================================

  String _getImagemFundo() {
    final p = widget.perfil.toLowerCase().trim();

    switch (p) {
      case 'professor':
        return 'assets/images/professor.png';

      case 'adulto':
        return 'assets/images/adulto.png';

      case 'crianca':
      default:
        return 'assets/images/crianca.png';
    }
  }

  // =========================================================
  // NÍVEL AUTOMÁTICO
  // =========================================================

  String _getNivelNomeParaService() {
    int fase = controller.state.fase;

    if (fase <= 3) return 'Bronze';

    if (fase <= 6) return 'Prata';

    if (fase <= 9) return 'Ouro';

    if (fase <= 12) return 'Platina';

    return 'Mestre';
  }

  // =========================================================
  // INICIAR
  // =========================================================

  void iniciar() {

    jogoAtivo = true;

    mensagem = '';

    tempoRestante = 60;

    controller.state.resetFase();

    gerarPergunta();

    iniciarTimer();

    setState(() {});
  }

  // =========================================================
  // GERAR PERGUNTA
  // =========================================================

  void gerarPergunta() {
    final p = service.gerar(
      perfil: widget.perfil,
      nivel: _getNivelNomeParaService(),
      fase: controller.state.fase,
    );

    setState(() {
      perguntaAtual = p;

      respostaController.clear();
    });

    // 🔥 FOCO AUTOMÁTICO
    Future.delayed(const Duration(milliseconds: 100), () {
      _garantirFoco();
    });
  }

  // =========================================================
  // TIMER
  // =========================================================

  void iniciarTimer() {
    timer?.cancel();

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (t) {
        if (!mounted || !jogoAtivo) {
          t.cancel();
          return;
        }

        if (tempoRestante <= 0) {
          t.cancel();

          _finalizarPorTempo();
        } else {
          setState(() {
            tempoRestante--;
          });
        }
      },
    );
  }

  // =========================================================
  // RESPONDER
  // =========================================================

  void responder() {

    if (!jogoAtivo || perguntaAtual == null) return;

    final resp = respostaController.text.trim();

    if (resp.isEmpty) return;

    final correto = resp == perguntaAtual!.resposta;

    final resultado = controller.responder(correto);

    // ❌ ERROU
    if (!correto) {

      _pararJogo(
        "❌ Resposta errada\n\n"
        "Resposta correta: ${perguntaAtual!.resposta}",
      );

      return;
    }

    // 🏆 FASE COMPLETA
    if (resultado == ResultadoResposta.faseCompleta) {

      final faseConcluida = controller.state.fase;

      controller.proximaFase();

      _pararJogo(
        "🏆 FASE $faseConcluida CONCLUÍDA!",
      );

    } else {

      // ✅ PRÓXIMA PERGUNTA
      gerarPergunta();
    }
  }

  // =========================================================
  // TEMPO ESGOTADO
  // =========================================================

  void _finalizarPorTempo() {

    _pararJogo(
      "⏰ Tempo esgotado!",
    );
  }

  // =========================================================
  // PARAR
  // =========================================================

  void _pararJogo(String msg) {

    timer?.cancel();

    setState(() {

      jogoAtivo = false;

      mensagem = msg;

      perguntaAtual = null;
    });
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        children: [

          // ===================================================
          // FUNDO
          // ===================================================

          Positioned.fill(
            child: Image.asset(
              _getImagemFundo(),
              fit: BoxFit.cover,
            ),
          ),

          // Overlay
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
            ),
          ),

          // ===================================================
          // CONTEÚDO
          // ===================================================

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),

              child: Column(
                children: [

                  _buildTopBar(),

                  const SizedBox(height: 20),

                  _buildGlassScoreBoard(),

                  const Spacer(),

                  _buildMainArea(),

                  const Spacer(),

                  // 🔥 BOTÃO CONFIRMAR
                  _buildFooterButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // TOPO
  // =========================================================

  Widget _buildTopBar() {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [

        IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white70,
          ),
          onPressed: () => Navigator.pop(context),
        ),

        Text(
          _getNivelNomeParaService().toUpperCase(),

          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),

        const SizedBox(width: 48),
      ],
    );
  }

  // =========================================================
  // PLACAR
  // =========================================================

  Widget _buildGlassScoreBoard() {

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),

        borderRadius: BorderRadius.circular(24),

        border: Border.all(
          color: Colors.white24,
        ),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,

        children: [

          _columnScore(
            "Fase",
            "${controller.state.fase}",
          ),

          _columnScore(
            "Tempo",
            "${tempoRestante}s",
            color: tempoRestante < 10
                ? Colors.redAccent
                : Colors.cyanAccent,
          ),

          _columnScore(
            "Pontos",
            "${controller.state.pontos}",
          ),
        ],
      ),
    );
  }

  Widget _columnScore(
    String l,
    String v, {
    Color color = Colors.white,
  }) {

    return Column(
      children: [

        Text(
          l.toUpperCase(),

          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),

        Text(
          v,

          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // ÁREA PRINCIPAL
  // =========================================================

  Widget _buildMainArea() {

    if (!jogoAtivo) {

      return Container(
        padding: const EdgeInsets.all(32),

        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),

          borderRadius: BorderRadius.circular(24),

          border: Border.all(
            color: Colors.white12,
          ),
        ),

        child: Text(
          mensagem,

          textAlign: TextAlign.center,

          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Column(
      children: [

        // PERGUNTA
        ScaleTransition(
          scale: Tween(
            begin: 1.0,
            end: 1.05,
          ).animate(_pulseController),

          child: Text(
            perguntaAtual?.pergunta ?? "",

            style: const TextStyle(
              color: Colors.white,
              fontSize: 60,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 30),

        // CAMPO RESPOSTA
        SizedBox(
          width: 220,

          child: TextField(
            controller: respostaController,

            focusNode: respostaFocusNode,

            autofocus: true,

            keyboardType: TextInputType.number,

            textInputAction: TextInputAction.done,

            textAlign: TextAlign.center,

            style: const TextStyle(
              color: Colors.orangeAccent,
              fontSize: 45,
              fontWeight: FontWeight.bold,
            ),

            decoration: const InputDecoration(
              hintText: "?",

              hintStyle: TextStyle(
                color: Colors.white30,
              ),

              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.orangeAccent,
                  width: 3,
                ),
              ),

              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.orange,
                  width: 4,
                ),
              ),
            ),

            // 🔥 ENTER CONFIRMA
            onSubmitted: (_) => responder(),
          ),
        ),
      ],
    );
  }

  // =========================================================
  // BOTÃO CONFIRMAR
  // =========================================================

  Widget _buildFooterButton() {

    return ElevatedButton(
      onPressed: responder,

      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.black,

        minimumSize: const Size(
          double.infinity,
          65,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),

        elevation: 10,
      ),

      child: const Text(
        "CONFIRMAR",

        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}