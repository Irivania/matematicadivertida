import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ErrorDialog extends StatelessWidget {
  final String mensagem;
  final VoidCallback onRetry;

  const ErrorDialog({
    super.key,
    required this.mensagem,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.backgroundEscuro,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.redAccent, width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Icon(
        Icons.error_outline, 
        color: Colors.redAccent, 
        size: 70, // Tamanho consistente com o SuccessDialog
      ),
      content: Text(
        mensagem,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white, 
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      actionsPadding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      actions: [
        Column(
          children: [
            // Botão Principal: Tentar Novamente
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onRetry();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  "TENTAR NOVAMENTE",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Botão Secundário: Sair (Para voltar ao menu)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "SAIR", 
                style: TextStyle(
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                )
              ),
            ),
          ],
        ),
      ],
    );
  }
}