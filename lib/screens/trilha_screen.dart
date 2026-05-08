import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audioplayers.dart';

class TrilhaScreen extends StatefulWidget {
  const TrilhaScreen({super.key});

  @override
  State<TrilhaScreen> createState() => _TrilhaScreenState();
}

class _TrilhaScreenState extends State<TrilhaScreen> {
  int faseAtual = 1;

  final AudioPlayer player = AudioPlayer();

  bool mostrarConfete = false;

  // =====================================================
  // FASES
  // =====================================================

  final List<Map<String, dynamic>> fases = [
    // Bronze
    {"numero": 1, "nivel": "Bronze", "icone": "🥉"},
    {"numero": 2, "nivel": "Bronze", "icone": "🥉"},
    {"numero": 3, "nivel": "Bronze", "icone": "🥉"},

    // Prata
    {"numero": 4, "nivel": "Prata", "icone": "🥈"},
    {"numero": 5, "nivel": "Prata", "icone": "🥈"},
    {"numero": 6, "nivel": "Prata", "icone": "🥈"},

    // Ouro
    {"numero": 7, "nivel": "Ouro", "icone": "🥇"},
    {"numero": 8, "nivel": "Ouro", "icone": "🥇"},
    {"numero": 9, "nivel": "Ouro", "icone": "🥇"},

    // Platina
    {"numero": 10, "nivel": "Platina", "icone": "💎"},
    {"numero": 11, "nivel": "Platina", "icone": "💎"},
    {"numero": 12, "nivel": "Platina", "icone": "💎"},

    // Mestre
    {"numero": 13, "nivel": "Mestre", "icone": "👑"},
    {"numero": 14, "nivel": "Mestre", "icone": "👑"},
    {"numero": 15, "nivel": "Mestre", "icone": "👑"},
  ];

  // =====================================================
  // CONCLUIR FASE
  // =====================================================

  void concluirFase(int numero) async {
    if (numero != faseAtual) return;

    setState(() {
      faseAtual++;
      mostrarConfete = true;
    });

    await player.play(
      AssetSource('sons/conquista.mp3'),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      setState(() {
        mostrarConfete = false;
      });
    });
  }

  // =====================================================
  // POSIÇÃO RESPONSIVA
  // =====================================================

  Offset calcularPosicao(
    int index,
    double largura,
    double altura,
  ) {
    double espacamentoX = largura * 0.18;

    double x = 60 + (index * espacamentoX);

    double y;

    if (index % 2 == 0) {
      y = altura * 0.72 - (index * 25);
    } else {
      y = altura * 0.58 - (index * 25);
    }

    return Offset(x, y);
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // =================================================
          // FUNDO
          // =================================================

          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF87CEFA),
                    Color(0xFFE3F2FD),
                    Colors.white,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // =================================================
          // NUVENS
          // =================================================

          const Positioned(
            top: 60,
            left: 40,
            child: Text(
              "☁️",
              style: TextStyle(fontSize: 50),
            ),
          ),

          const Positioned(
            top: 120,
            right: 60,
            child: Text(
              "☁️",
              style: TextStyle(fontSize: 70),
            ),
          ),

          // =================================================
          // TRILHA
          // =================================================

          CustomPaint(
            size: Size(
              size.width,
              size.height,
            ),
            painter: CaminhoTrilhaPainter(),
          ),

          // =================================================
          // SCROLL
          // =================================================

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 1600,
              height: size.height,
              child: Stack(
                children: [
                  // =========================================
                  // FASES
                  // =========================================

                  for (int i = 0; i < fases.length; i++)
                    Builder(
                      builder: (_) {
                        final fase = fases[i];

                        final pos = calcularPosicao(
                          i,
                          1400,
                          size.height,
                        );

                        return Positioned(
                          left: pos.dx,
                          top: pos.dy,
                          child: FaseWidget(
                            numero: fase["numero"],
                            faseAtual: faseAtual,
                            onTap: concluirFase,
                            icone: fase["icone"],
                          ),
                        );
                      },
                    ),

                  // =========================================
                  // MASCOTES
                  // =========================================

                  const Positioned(
                    left: 20,
                    bottom: 40,
                    child: MascoteAnimado(
                      emoji: "🐵",
                      nome: "Bronze",
                    ),
                  ),

                  const Positioned(
                    left: 340,
                    bottom: 180,
                    child: MascoteAnimado(
                      emoji: "🐺",
                      nome: "Prata",
                    ),
                  ),

                  const Positioned(
                    left: 650,
                    bottom: 320,
                    child: MascoteAnimado(
                      emoji: "🦊",
                      nome: "Ouro",
                    ),
                  ),

                  const Positioned(
                    left: 980,
                    bottom: 470,
                    child: MascoteAnimado(
                      emoji: "🦄",
                      nome: "Platina",
                    ),
                  ),

                  const Positioned(
                    left: 1280,
                    bottom: 620,
                    child: MascoteAnimado(
                      emoji: "🐉",
                      nome: "Mestre",
                    ),
                  ),
                ],
              ),
            ),
          ),

          // =================================================
          // CONFETE
          // =================================================

          if (mostrarConfete)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.black.withOpacity(0.2),
                  child: Center(
                    child: TweenAnimationBuilder(
                      tween: Tween<double>(
                        begin: 0.5,
                        end: 1.2,
                      ),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: child,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "🎉",
                              style: TextStyle(fontSize: 70),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Parabéns!",
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple.shade700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Fase concluída com sucesso!",
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// =========================================================
// CAMINHO DA TRILHA
// =========================================================

class CaminhoTrilhaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sombra = Paint()
      ..color = Colors.black12
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Colors.orange,
          Colors.deepOrange,
        ],
      ).createShader(
        Rect.fromLTWH(
          0,
          0,
          size.width,
          size.height,
        ),
      )
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(60, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.2,
        size.height * 0.55,
        size.width * 0.4,
        size.height * 0.62,
      )
      ..quadraticBezierTo(
        size.width * 0.6,
        size.height * 0.8,
        size.width * 0.8,
        size.height * 0.42,
      )
      ..quadraticBezierTo(
        size.width * 0.9,
        size.height * 0.2,
        size.width,
        size.height * 0.35,
      );

    canvas.drawPath(path, sombra);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

// =========================================================
// FASE
// =========================================================

class FaseWidget extends StatefulWidget {
  final int numero;
  final int faseAtual;
  final Function(int) onTap;
  final String icone;

  const FaseWidget({
    super.key,
    required this.numero,
    required this.faseAtual,
    required this.onTap,
    required this.icone,
  });

  @override
  State<FaseWidget> createState() => _FaseWidgetState();
}

class _FaseWidgetState extends State<FaseWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _animacao;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _animacao = Tween<double>(
      begin: 1,
      end: 1.08,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(
      reverse: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool desbloqueada = widget.numero <= widget.faseAtual;

    bool concluida = widget.numero < widget.faseAtual;

    return GestureDetector(
      onTap: desbloqueada
          ? () => widget.onTap(widget.numero)
          : null,
      child: ScaleTransition(
        scale: desbloqueada
            ? _animacao
            : const AlwaysStoppedAnimation(1),
        child: Column(
          children: [
            Text(
              widget.icone,
              style: const TextStyle(
                fontSize: 36,
              ),
            ),

            const SizedBox(height: 6),

            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: concluida
                    ? const LinearGradient(
                        colors: [
                          Colors.green,
                          Colors.lightGreen,
                        ],
                      )
                    : desbloqueada
                        ? const LinearGradient(
                            colors: [
                              Colors.orange,
                              Colors.deepOrange,
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              Colors.grey.shade500,
                              Colors.grey.shade700,
                            ],
                          ),
                boxShadow: [
                  BoxShadow(
                    color: desbloqueada
                        ? Colors.orange.withOpacity(0.5)
                        : Colors.black12,
                    blurRadius: 14,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: concluida
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 34,
                      )
                    : Text(
                        "${widget.numero}",
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================
// MASCOTE ANIMADO
// =========================================================

class MascoteAnimado extends StatefulWidget {
  final String emoji;
  final String nome;

  const MascoteAnimado({
    super.key,
    required this.emoji,
    required this.nome,
  });

  @override
  State<MascoteAnimado> createState() => _MascoteAnimadoState();
}

class _MascoteAnimadoState extends State<MascoteAnimado>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  late Animation<double> _animacao;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _animacao = Tween<double>(
      begin: 1,
      end: 1.15,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticInOut,
      ),
    );
  }

  void _pular() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pular,
      child: ScaleTransition(
        scale: _animacao,
        child: Column(
          children: [
            Text(
              widget.emoji,
              style: const TextStyle(
                fontSize: 54,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                widget.nome,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}