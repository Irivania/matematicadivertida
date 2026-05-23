// lib/presentation/widgets/jogo/progress_widget.dart

import 'package:flutter/material.dart';

class ProgressWidget extends StatelessWidget {
  final int perguntaAtual;
  final int totalPerguntas;
  final bool disputaAtiva;

  const ProgressWidget({
    super.key,
    required this.perguntaAtual,
    required this.totalPerguntas,
    required this.disputaAtiva,
  });

  @override
  Widget build(BuildContext context) {
    final double progresso =
        totalPerguntas > 0
            ? perguntaAtual / totalPerguntas
            : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 40,
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progresso.clamp(0.0, 1.0),
              minHeight: 12,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(
                disputaAtiva
                    ? Colors.purpleAccent
                    : Colors.greenAccent,
              ),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            "$perguntaAtual / $totalPerguntas",
            style: TextStyle(
              color: disputaAtiva
                  ? Colors.white
                  : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}