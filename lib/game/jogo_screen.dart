import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/pergunta_service.dart';
import '../models/pergunta.dart';
import '../controllers/game_controller.dart';

class JogoScreen extends StatefulWidget {
  final String perfil;
  const JogoScreen({super.key, required this.perfil});

  @override
  State<JogoScreen> createState() => _JogoScreenState();
}

class _JogoScreenState extends State<JogoScreen> with SingleTickerProviderStateMixin {
  final service = PerguntaService();
  final controller = GameController();
  
  Pergunta? perguntaAtualObjeto;
  final respostaController = TextEditingController();
  final FocusNode respostaFocusNode = FocusNode();
  
  Timer? timer;
  int tempoRestante = 60;
  bool jogoAtivo = false;
  String mensagem = '';
  bool erroNaResposta = false;
  int recordeDePontos = 0;

  @override
  void initState() {
    super.initState();
    _carregarRecorde();
    WidgetsBinding.instance.addPostFrameCallback((_) => iniciar());
  }

  @override
  void dispose() {
    timer?.cancel();
    respostaController.dispose();
    respostaFocusNode.dispose();
    super.dispose();
  }

  void _focarCampo() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        FocusScope.of(context).requestFocus(respostaFocusNode);
      }
    });
  }

  Future<void> _carregarRecorde() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => recordeDePontos = prefs.getInt('recorde_${widget.perfil}') ?? 0);
  }

  void iniciar() {
    setState(() {
      controller.state.resetFase();
      jogoAtivo = true;
      erroNaResposta = false;
      mensagem = '';
      tempoRestante = 60;
      gerarPergunta();
      iniciarTimer();
    });
    _focarCampo();
  }

  void gerarPergunta() {
    final p = service.gerar(
      perfil: widget.perfil,
      nivel: controller.getNomeNivel(), 
      fase: controller.state.fase,
    );
    setState(() {
      perguntaAtualObjeto = p;
      respostaController.clear();
      erroNaResposta = false;
    });
    _focarCampo();
  }

  void iniciarTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || !jogoAtivo) return;
      if (tempoRestante <= 0) _pararJogo("Tempo Esgotado!", true);
      else setState(() => tempoRestante--);
    });
  }

  void responder() {
    if (!jogoAtivo) {
      iniciar();
      return;
    }

    if (perguntaAtualObjeto == null || respostaController.text.isEmpty) return;

    final correto = respostaController.text.trim() == perguntaAtualObjeto!.resposta;
    final resultado = controller.responder(correto);

    if (!correto) {
      _pararJogo("A resposta correta era ${perguntaAtualObjeto!.resposta}", true);
    } else if (resultado == ResultadoResposta.faseCompleta) {
      _pararJogo("Fase Concluída!", false);
      controller.proximaFase();
    } else {
      gerarPergunta();
    }
  }

  void _pararJogo(String msg, bool foiErro) {
    timer?.cancel();
    setState(() {
      jogoAtivo = false;
      mensagem = msg;
      erroNaResposta = foiErro;
    });
    _focarCampo();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter): () => responder(),
        const SingleActivator(LogicalKeyboardKey.numpadEnter): () => responder(),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  _getImagemFundo(), 
                  fit: BoxFit.cover, 
                  alignment: Alignment.topCenter
                )
              ),
              SafeArea(
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.38), 
                    _buildHUD(),
                    const SizedBox(height: 12),
                    Text(
                      "PERGUNTA ${controller.state.perguntaAtual + 1} / ${controller.state.perguntasPorFase}",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHUD() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: const Color(0xCC000000), // Preto com opacidade
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatusItem(controller.getNomeNivelFormatado(), "NÍVEL"),
            _buildStatusItem("FASE ${controller.state.fase}", "PROGRESSO"),
            _buildStatusItem("${tempoRestante}s", "TEMPO", 
                color: tempoRestante < 10 ? Colors.redAccent : Colors.cyanAccent),
            _buildStatusItem("${controller.state.pontos}", "PONTOS"),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String value, String label, {Color color = Colors.white}) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 9)),
      ],
    );
  }

  Widget _buildProgressBar() {
    double progresso = controller.state.perguntaAtual / controller.state.perguntasPorFase;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: progresso.clamp(0.0, 1.0), 
          minHeight: 8, 
          backgroundColor: Colors.white10, 
          color: Colors.greenAccent
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (!jogoAtivo) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 30),
        margin: const EdgeInsets.symmetric(horizontal: 40),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5), // Cinza muito claro (quase branco)
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: erroNaResposta ? Colors.red.withOpacity(0.5) : Colors.green.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              erroNaResposta ? Icons.cancel_rounded : Icons.check_circle_rounded,
              color: erroNaResposta ? Colors.redAccent : Colors.green,
              size: 60,
            ),
            const SizedBox(height: 10),
            Text(
              erroNaResposta ? "OPS, VOCÊ ERROU!" : "MUITO BEM!",
              style: TextStyle(
                color: erroNaResposta ? Colors.redAccent : const Color(0xFF2E7D32),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF212121), fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 15),
            const Text(
              "[ Pressione ENTER ]",
              style: TextStyle(color: Colors.black38, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Text(
          perguntaAtualObjeto?.pergunta ?? "", 
          style: const TextStyle(
            color: Colors.white, fontSize: 54, fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black, blurRadius: 10)]
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          width: 200,
          child: TextField(
            controller: respostaController,
            focusNode: respostaFocusNode,
            autofocus: true,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.orangeAccent, fontSize: 55, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              hintText: "?", 
              hintStyle: TextStyle(color: Colors.white24),
              border: InputBorder.none,
            ),
            onSubmitted: (_) => responder(),
            onTapOutside: (_) => _focarCampo(),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: ElevatedButton(
        onPressed: responder,
        style: ElevatedButton.styleFrom(
          backgroundColor: jogoAtivo ? Colors.orange : (erroNaResposta ? Colors.redAccent : Colors.green),
          minimumSize: const Size(double.infinity, 60),
        ),
        child: Text(
          jogoAtivo ? "CONFIRMAR" : (erroNaResposta ? "TENTAR DE NOVO" : "PRÓXIMA FASE"),
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  String _getImagemFundo() {
    final p = widget.perfil.toLowerCase().trim();
    if (p == 'professor') return 'assets/images/professor.png';
    if (p == 'adulto') return 'assets/images/adulto.png';
    return 'assets/images/crianca.png';
  }
}