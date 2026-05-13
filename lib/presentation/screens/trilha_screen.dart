import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class TrilhaScreen extends StatefulWidget {
  const TrilhaScreen({super.key});

  @override
  State<TrilhaScreen> createState() => _TrilhaScreenState();
}

class _TrilhaScreenState extends State<TrilhaScreen> {
  int faseAtual = 1;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool mostrarConfete = false;

  // Configurações da Trilha
  final double larguraTrilha = 2000;

  final List<Map<String, dynamic>> fases = [
    {"numero": 1, "nivel": "Bronze", "icone": "🥉"},
    {"numero": 2, "nivel": "Bronze", "icone": "🥉"},
    {"numero": 3, "nivel": "Bronze", "icone": "🥉"},
    {"numero": 4, "nivel": "Prata", "icone": "🥈"},
    {"numero": 5, "nivel": "Prata", "icone": "🥈"},
    {"numero": 6, "nivel": "Prata", "icone": "🥈"},
    {"numero": 7, "nivel": "Ouro", "icone": "🥇"},
    {"numero": 8, "nivel": "Ouro", "icone": "🥇"},
    {"numero": 9, "nivel": "Ouro", "icone": "🥇"},
    {"numero": 10, "nivel": "Platina", "icone": "💎"},
    {"numero": 11, "nivel": "Platina", "icone": "💎"},
    {"numero": 12, "nivel": "Platina", "icone": "💎"},
    {"numero": 13, "nivel": "Mestre", "icone": "👑"},
    {"numero": 14, "nivel": "Mestre", "icone": "👑"},
    {"numero": 15, "nivel": "Mestre", "icone": "👑"},
  ];

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void concluirFase(int numero) async {
    if (numero != faseAtual) return;

    setState(() {
      faseAtual++;
      mostrarConfete = true;
    });

    try {
      // Certifique-se de que o arquivo existe em assets/sons/conquista.mp3
      await _audioPlayer.play(AssetSource('sons/conquista.mp3'));
    } catch (e) {
      debugPrint("Erro ao tocar som: $e");
    }

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => mostrarConfete = false);
    });
  }

  Offset _getPosicaoFase(int index, Size size) {
    double x = 100 + (index * 130.0);
    double y = (size.height * 0.5) + (index % 2 == 0 ? 60 : -60);
    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 1. FUNDO GRADIENTE
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF87CEFA), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 2. ELEMENTOS DECORATIVOS
          const Positioned(top: 50, left: 30, child: Text("☁️", style: TextStyle(fontSize: 40))),
          const Positioned(top: 100, right: 40, child: Text("☁️", style: TextStyle(fontSize: 60))),

          // 3. ÁREA DE SCROLL
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              width: larguraTrilha,
              height: size.height,
              child: Stack(
                children: [
                  // LINHA DA TRILHA
                  // Removido 'const' pois depende do Painter que recebe funções dinâmicas
                  CustomPaint(
                    size: Size(larguraTrilha, size.height),
                    painter: TrilhaPainter(
                      fasesCount: fases.length,
                      getPos: (i) => _getPosicaoFase(i, size),
                    ),
                  ),

                  // MASCOTES
                  _buildMascote(2, "🐵", "Bronze", size),
                  _buildMascote(5, "🐺", "Prata", size),
                  _buildMascote(8, "🦊", "Ouro", size),
                  _buildMascote(11, "🦄", "Platina", size),
                  _buildMascote(14, "🐉", "Mestre", size),

                  // WIDGETS DAS FASES
                  ...fases.asMap().entries.map((entry) {
                    final pos = _getPosicaoFase(entry.key, size);
                    return Positioned(
                      left: pos.dx - 35,
                      top: pos.dy - 50,
                      child: FaseWidget(
                        numero: entry.value["numero"],
                        faseAtual: faseAtual,
                        icone: entry.value["icone"],
                        onTap: concluirFase,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // 4. OVERLAY DE SUCESSO
          if (mostrarConfete) _buildSuccessOverlay(),
        ],
      ),
    );
  }

  Widget _buildMascote(int faseIndex, String emoji, String nome, Size size) {
    final pos = _getPosicaoFase(faseIndex, size);
    return Positioned(
      left: pos.dx - 20,
      top: pos.dy + 60,
      child: MascoteAnimado(emoji: emoji, nome: nome),
    );
  }

  Widget _buildSuccessOverlay() {
    return Container(
      color: Colors.black26,
      child: Center(
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          builder: (context, double val, child) {
            return Transform.scale(scale: val, child: child);
          },
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 10,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("🎉", style: TextStyle(fontSize: 60)),
                  Text("Incrível!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  Text("Você avançou na trilha!"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- WIDGETS AUXILIARES ---

class FaseWidget extends StatelessWidget {
  final int numero;
  final int faseAtual;
  final String icone;
  final Function(int) onTap;

  const FaseWidget({
    super.key,
    required this.numero,
    required this.faseAtual,
    required this.icone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool concluida = numero < faseAtual;
    final bool bloqueada = numero > faseAtual;

    return GestureDetector(
      onTap: () => onTap(numero),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: bloqueada ? Colors.grey : (concluida ? Colors.green : Colors.orange),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Center(
              child: Text(
                bloqueada ? "🔒" : icone,
                style: const TextStyle(fontSize: 30),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Fase $numero",
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class MascoteAnimado extends StatelessWidget {
  final String emoji;
  final String nome;

  const MascoteAnimado({super.key, required this.emoji, required this.nome});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 10),
          duration: const Duration(seconds: 1),
          builder: (context, double value, child) {
            final double jump = value > 5 ? (10 - value) : value;
            return Transform.translate(
              offset: Offset(0, -jump),
              child: Text(emoji, style: const TextStyle(fontSize: 45)),
            );
          },
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            nome,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class TrilhaPainter extends CustomPainter {
  final int fasesCount;
  final Offset Function(int) getPos;

  TrilhaPainter({required this.fasesCount, required this.getPos});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange.withValues(alpha: 0.6)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    for (int i = 0; i < fasesCount; i++) {
      Offset p = getPos(i);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        Offset prev = getPos(i - 1);
        path.cubicTo(
          prev.dx + 50, prev.dy, 
          p.dx - 50, p.dy, 
          p.dx, p.dy
        );
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant TrilhaPainter oldDelegate) {
    return oldDelegate.fasesCount != fasesCount;
  }
}