import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SuccessDialog extends StatelessWidget {
  final int acertos;
  final VoidCallback onNext;
  final Duration? tempoGasto;       // Novo parâmetro opcional
  final bool isRecordePessoal;     // Novo parâmetro opcional

  const SuccessDialog({
    super.key,
    required this.acertos,
    required this.onNext,
    this.tempoGasto,
    this.isRecordePessoal = false,
  });

  @override
  Widget build(BuildContext context) {
    // Função auxiliar para formatar o tempo gasto de forma amigável
    String formatarTempo(Duration duration) {
      final minutos = duration.inMinutes;
      final segundos = duration.inSeconds % 60;
      if (minutos > 0) {
        return '${minutos}m ${segundos}s';
      }
      return '${segundos}s';
    }

    return AlertDialog(
      backgroundColor: AppColors.backgroundEscuro,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.greenAccent, width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Icon(
        Icons.check_circle_outline, 
        color: Colors.greenAccent, 
        size: 70, 
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Fase Concluída!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white, 
              fontSize: 22, 
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Você acertou $acertos questões!",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70, 
              fontSize: 16,
            ),
          ),

          // Se houver tempo gasto (Modo Disputa), exibe abaixo da contagem de acertos
          if (tempoGasto != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.timer, color: Colors.greenAccent, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    "Tempo total: ${formatarTempo(tempoGasto!)}",
                    style: const TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Se for recorde pessoal, mostra o badge comemorativo combinando com o tema
          if (isRecordePessoal) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withValues(alpha: 0.1),
                border: Border.all(color: Colors.greenAccent, width: 1.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.flash_on, color: Colors.greenAccent, size: 16),
                  SizedBox(width: 4),
                  Text(
                    "NOVO RECORDE!",
                    style: TextStyle(
                      color: Colors.greenAccent, 
                      fontWeight: FontWeight.bold, 
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actionsPadding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      actions: [
        SizedBox(
          width: double.infinity, 
          child: ElevatedButton(
            onPressed: onNext, // Removido o pop extra para seguir a lógica da sua Screen
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              "PRÓXIMA FASE", 
              style: TextStyle(
                color: AppColors.backgroundEscuro,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}