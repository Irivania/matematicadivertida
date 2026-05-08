import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui'; 
import '../services/pergunta_service.dart';
import '../models/pergunta.dart';
import '../controllers/game_controller.dart';

class JogoScreen extends StatefulWidget {
  final String perfil; // "crianca", "adulto" ou "professor"

  const JogoScreen({super.key, required this.perfil});

  @override
  State<JogoScreen> createState() => _JogoScreenState();
}

class _JogoScreenState extends State<JogoScreen> with SingleTickerProviderStateMixin {
  final service = PerguntaService();
  final controller = GameController();
  Pergunta? perguntaAtual;
  final respostaController = TextEditingController();
  final FocusNode respostaFocusNode = FocusNode();
  
  Timer? timer;
  int tempoRestante = 60;
  bool jogoAtivo = false;
  bool aguardandoProximaFase = false;
  String mensagem = 'Pressione ENTER para iniciar';

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    // Focar no campo de texto automaticamente após a montagem da tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      respostaFocusNode.requestFocus();
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

  // --- Lógica de Seleção de Imagem Corrigida ---
  String _getImagemFundo() {
    // Normalizamos a string para evitar erros de acentuação ou caixa alta
    final p = widget.perfil.toLowerCase().trim();
    if (p.contains('crianca') || p.contains('criança')) {
      return 'assets/images/fundo_crianca.png';
    } else if (p.contains('adulto')) {
      return 'assets/images/fundo_adulto.png';
    } else if (p.contains('professor')) {
      return 'assets/images/fundo_professor.png';
    }
    return 'assets/images/fundo_crianca.png'; // Fallback
  }

  // --- Lógica do Jogo ---
  void iniciar() {
    setState(() {
      jogoAtivo = true;
      aguardandoProximaFase = false;
      mensagem = '';
      tempoRestante = 60;
    });
    controller.state.resetFase();
    gerarPergunta();
    iniciarTimer();
  }

  void gerarPergunta() {
    final p = service.gerar(
      perfil: widget.perfil,
      nivel: _getNivelNome(),
      fase: controller.state.fase,
    );
    setState(() {
      perguntaAtual = p;
      respostaController.clear();
    });
    respostaFocusNode.requestFocus();
  }

  void iniciarTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted || !jogoAtivo) { t.cancel(); return; }
      if (tempoRestante <= 0) { 
        t.cancel(); 
        _finalizarPorTempo(); 
      } else { 
        setState(() => tempoRestante--); 
      }
    });
  }

  void responder() {
    if (!jogoAtivo || perguntaAtual == null) return;
    final resp = respostaController.text.trim();
    if (resp.isEmpty) return;

    final correto = resp == perguntaAtual!.resposta;
    // Assume-se que controller.responder retorna um enum ou String
    final resultado = controller.responder(correto);

    if (!correto) {
      _pararJogo("❌ Ops! Resposta errada.\nA resposta era: ${perguntaAtual!.resposta}");
      return;
    }

    // Ajuste conforme o nome exato do seu enum no GameController
    if (resultado.toString().contains('faseCompleta')) {
      final faseConcluida = controller.state.fase;
      controller.proximaFase();
      _pararJogo("🏆 FASE $faseConcluida CONCLUÍDA!\n🚀 Pressione ENTER para continuar");
      aguardandoProximaFase = true;
    } else {
      gerarPergunta();
    }
  }

  void _finalizarPorTempo() {
    _pararJogo("⏰ O tempo acabou!\nVamos tentar de novo?");
  }

  void _pararJogo(String msg) {
    timer?.cancel();
    setState(() {
      jogoAtivo = false;
      mensagem = msg;
      perguntaAtual = null;
    });
  }

  String _getNivelNome() {
    int fase = controller.state.fase;
    if (fase <= 5) return 'Iniciante';
    if (fase <= 10) return 'Intermediário';
    return 'Mestre';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos KeyboardListener para maior compatibilidade
      body: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
            jogoAtivo ? responder() : iniciar();
          }
        },
        child: Stack(
          children: [
            // Camada 1: Imagem de Fundo
            Container(
              key: ValueKey(_getImagemFundo()), // Força rebuild se mudar o perfil
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(_getImagemFundo()),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Camada 2: Overlay de leitura
            Container(color: Colors.black.withOpacity(0.45)),

            // Camada 3: Conteúdo Principal
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildGlassScoreBoard(),
                    const Spacer(),
                    _buildMainArea(),
                    const Spacer(),
                    _buildFooterButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      "MATEMÁTICA DIVERTIDA",
      style: TextStyle(
        color: Colors.white,
        fontSize: 26,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
        shadows: [
          Shadow(color: Colors.orangeAccent.withOpacity(0.8), blurRadius: 12),
          const Shadow(color: Colors.black, offset: Offset(2, 2)),
        ],
      ),
    );
  }

  Widget _buildGlassScoreBoard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _scoreItem("Fase", "${controller.state.fase}"),
              _scoreItem("Tempo", "${tempoRestante}s", 
                color: tempoRestante < 10 ? Colors.redAccent : Colors.cyanAccent),
              _scoreItem("Pontos", "${controller.state.pontos}"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scoreItem(String label, String value, {Color color = Colors.white}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildMainArea() {
    if (!jogoAtivo) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
        ),
        child: Text(
          mensagem,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      );
    }

    return Column(
      children: [
        Text(
          perguntaAtual?.pergunta ?? "",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 72,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black, blurRadius: 20)],
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: 180,
          child: TextField(
            controller: respostaController,
            focusNode: respostaFocusNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            autofocus: true,
            cursorColor: Colors.orangeAccent,
            style: const TextStyle(color: Colors.orangeAccent, fontSize: 56, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              hintText: "?",
              hintStyle: TextStyle(color: Colors.white12),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.orangeAccent, width: 5)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.orangeAccent, width: 5)),
            ),
            onSubmitted: (_) => responder(),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterButton() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: jogoAtivo ? 1.0 : 1.0 + (0.04 * _pulseController.value),
          child: ElevatedButton(
            onPressed: jogoAtivo ? responder : iniciar,
            style: ElevatedButton.styleFrom(
              backgroundColor: jogoAtivo ? Colors.cyanAccent : Colors.orangeAccent,
              foregroundColor: Colors.black,
              minimumSize: const Size(double.infinity, 75),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 12,
            ),
            child: Text(
              jogoAtivo ? "CONFIRMAR RESPOSTA" : "INICIAR DESAFIO",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
          ),
        );
      },
    );
  }
}