import 'package:flutter/material.dart';
import 'package:matematicadivertida/data/models/game_state.dart';
import 'package:matematicadivertida/core/enums/nivel_ext.dart'; // Importante para as extensões do Enum
import 'package:matematicadivertida/core/theme/app_colors.dart';

class GameHud extends StatelessWidget {
  final GameState state;

  const GameHud({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    // CORREÇÃO: Acessamos 'nivelAtual' (o Enum) para usar as extensões .label e .serie
    final nivelEnum = state.nivelAtual;

    return Card(
      elevation: 8,
      color: AppColors.backgroundCard.withValues(alpha: 0.9),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: AppColors.neonCiano, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // FASE
            Text(
              "🏆 FASE ${state.fase}",
              style: const TextStyle(
                color: AppColors.neonAmarelo,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),

            const Divider(color: Colors.white24, height: 20),

            // PROGRESSO E ACERTOS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Ajustado para mostrar o número atual da pergunta
                _buildInfoItem("📘 Questão", "${state.perguntaAtual}/10"),
                _buildInfoItem("✅ Acertos", "${state.acertos}"),
              ],
            ),

            const SizedBox(height: 12),

            // PONTUAÇÃO
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.neonVerde.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "🎯 ${state.pontos} PTS",
                style: const TextStyle(
                  fontSize: 20,
                  color: AppColors.neonVerde,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // NÍVEL E SÉRIE
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.school, color: Colors.white60, size: 16),
                const SizedBox(width: 5),
                Text(
                  // CORREÇÃO: Usamos .label (ou .name) e .serie definidos na extensão do Enum
                  "${nivelEnum.label} • ${nivelEnum.serie}", 
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white60,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}