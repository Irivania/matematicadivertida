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
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDisputa ? Colors.black.withOpacity(0.8) : Colors.white.withAlpha(230),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildItem("FASE", "${state.fase}/10", isDisputa),
          _buildItem("PERGUNTA", "${state.indicePerguntaAtual}/${state.maxPerguntasPorFase}", isDisputa),
          _buildItem("TEMPO", isDisputa ? state.formatarMinutos(state.tempoAcumuladoNivel) : "${tempoRestante}s", isDisputa, destaque: true),
          _buildItem("XP", "${state.pontos}", isDisputa),
        ],
      ),
    );
  }

  Widget _buildItem(String label, String valor, bool isDisputa, {bool destaque = false}) {
    return Column(
      children: [
        Text(valor, style: TextStyle(
          fontWeight: FontWeight.bold, 
          fontSize: 16, 
          color: destaque && isDisputa ? Colors.purpleAccent : (isDisputa ? Colors.white : Colors.black)
        )),
        Text(label, style: TextStyle(fontSize: 10, color: isDisputa ? Colors.white60 : Colors.grey)),
      ],
    );
  }
}