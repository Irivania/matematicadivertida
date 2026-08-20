// lib/presentation/widgets/jogo/progress_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/game_state.dart';

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
    // Escuta o idioma para alternar dinamicamente entre Português e Inglês
    final gs = context.watch<GameState>();
    final bool eIngles = gs.currentLocale.languageCode == 'en';

    // Garante que o progresso sempre tenha um mínimo visual para a barra não sumir
    final double progresso = totalPerguntas > 0 
        ? (perguntaAtual / totalPerguntas).clamp(0.05, 1.0) 
        : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: Column(
        children: [
          // Barra de progresso com um brilho suave
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progresso,
              minHeight: 14, // Um pouco maior para melhor visualização
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                disputaAtiva ? Colors.purpleAccent : Colors.greenAccent,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Texto com sombra para garantir leitura em qualquer fundo
          Text(
            eIngles 
              ? "QUESTION $perguntaAtual OF $totalPerguntas" 
              : "PERGUNTA $perguntaAtual DE $totalPerguntas",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
              letterSpacing: 1.2,
              shadows: [
                Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1))
              ],
            ),
          ),
        ],
      ),
    );
  }
}