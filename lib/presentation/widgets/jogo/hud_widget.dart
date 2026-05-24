// lib/presentation/widgets/jogo/hud_widget.dart
import 'package:flutter/material.dart';
import '../../../data/models/game_state.dart';

class HUDWidget extends StatelessWidget {
  final GameState state;
  final bool isDisputa;
  final int tempoRestante;

  const HUDWidget({
    super.key, 
    required this.state, 
    required this.isDisputa, 
    required this.tempoRestante
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isDisputa 
            ? Colors.black.withOpacity(0.7) 
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDisputa ? Colors.purpleAccent : Colors.greenAccent, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildItem(Icons.layers, "FASE", "${state.fase}/10"),
          _buildItem(Icons.help_outline, "QST", "${state.indicePerguntaAtual}/${state.maxPerguntasPorFase}"),
          _buildItem(Icons.timer, "TIME", isDisputa ? state.formatarMinutos(state.tempoAcumuladoNivel) : "${tempoRestante}s", destaque: true),
          _buildItem(Icons.star, "XP", "${state.pontos}"),
        ],
      ),
    );
  }

  Widget _buildItem(IconData icon, String label, String valor, {bool destaque = false}) {
    final Color corPrincipal = isDisputa ? Colors.white : Colors.black87;
    final Color corDestaque = destaque ? (isDisputa ? Colors.purpleAccent : Colors.green[700]!) : corPrincipal;

    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: corDestaque),
            const SizedBox(width: 4),
            Text(valor, style: TextStyle(
              fontWeight: FontWeight.w900, 
              fontSize: 16, 
              color: corDestaque
            )),
          ],
        ),
        Text(label, style: TextStyle(
          fontSize: 9, 
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
          color: isDisputa ? Colors.white60 : Colors.black54
        )),
      ],
    );
  }
}