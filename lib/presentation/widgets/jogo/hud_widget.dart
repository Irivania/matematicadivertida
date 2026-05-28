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
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      decoration: BoxDecoration(
        color: isDisputa ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isDisputa ? Colors.purpleAccent : Colors.greenAccent, width: 1.2),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 1))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildItemFase(),
          
          // Tempo: Agora usa formatarMinutos para ambos os modos
          _buildItem(
            Icons.timer, 
            "TIME", 
            state.formatarMinutos(tempoRestante), // Formato 00:00 padronizado
            destaque: true
          ),
          
          // XP
          _buildItem(Icons.star, "XP", "${state.pontos}"),
        ],
      ),
    );
  }

  Widget _buildItemFase() {
    final Color cor = isDisputa ? Colors.white : Colors.black87;
    final nivel = state.nivelAtual;
    return Row(
      children: [
        Icon(nivel.icone, size: 18, color: nivel.cor),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("${state.fase}", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: cor)),
            Text(nivel.label.toUpperCase(), style: const TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildItem(IconData icon, String label, String valor, {bool destaque = false}) {
    final Color corDestaque = destaque 
        ? (isDisputa ? Colors.purpleAccent : Colors.green[700]!) 
        : (isDisputa ? Colors.white : Colors.black87);
    
    return Row(
      children: [
        Icon(icon, size: 12, color: corDestaque),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(valor, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: corDestaque)),
            Text(label, style: const TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Colors.grey)),
          ],
        ),
      ],
    );
  }
}