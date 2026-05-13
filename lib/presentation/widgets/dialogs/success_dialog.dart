import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SuccessDialog extends StatelessWidget {
  final int acertos;
  final VoidCallback onNext;

  const SuccessDialog({
    super.key,
    required this.acertos,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.backgroundEscuro,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.greenAccent, width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Icon(
        Icons.check_circle_outline, 
        color: Colors.greenAccent, 
        size: 70, // Aumentado levemente para impacto visual
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
        ],
      ),
      actionsPadding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      actions: [
        SizedBox(
          width: double.infinity, // Botão ocupando a largura total para facilitar o toque
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onNext();
            },
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