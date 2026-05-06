import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../core/enums/nivel_ext.dart';

class GameHud extends StatelessWidget {
  final GameState state;

  const GameHud({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    // 🔥 AGORA VEM DO ESTADO REAL DO JOGO
    final nivel = state.nivel;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // =========================
            // FASE
            // =========================
            Text(
              "🏆 Fase ${state.fase}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // =========================
            // PROGRESSO
            // =========================
            Text("📘 Pergunta: ${state.perguntaAtual + 1}/10"),
            Text("✅ Acertos: ${state.acertos}"),

            const SizedBox(height: 8),

            // =========================
            // PONTOS
            // =========================
            Text(
              "🎯 Pontos: ${state.pontos}",
              style: const TextStyle(
                fontSize: 18,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // =========================
            // 🔥 NÍVEL E SÉRIE
            // =========================
            const Divider(),

            Text(
              "🥇 Nível: ${nivel.nome}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "🎓 Série: ${nivel.serie}",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}