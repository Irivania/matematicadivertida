import 'package:flutter/material.dart';
import '../models/game_state.dart';

class GameHud extends StatelessWidget {
  final GameState state;

  const GameHud({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🏆 FASE
            Text(
              "🏆 Fase ${state.fase}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // 📊 PERGUNTAS (0 → 10 corrigido para 1 → 10 visual)
            Text(
              "📘 Pergunta: ${state.perguntaAtual + 1}/10",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 4),

            // ✅ ACERTOS
            Text(
              "✅ Acertos: ${state.acertos}",
              style: const TextStyle(fontSize: 16),
            ),

            const SizedBox(height: 4),

            // 🎯 PONTOS
            Text(
              "🎯 Pontos: ${state.pontos}",
              style: const TextStyle(
                fontSize: 18,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}