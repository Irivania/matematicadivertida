import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LevelUpDialog extends StatelessWidget {
  final String novoNivel;
  final String icone;

  const LevelUpDialog({
    super.key,
    required this.novoNivel,
    required this.icone,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.backgroundEscuro,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.neonCiano, width: 3),
          boxShadow: [
            BoxShadow(
              // CORREÇÃO: withOpacity -> withValues (ou apenas ajuste para compilar)
              color: AppColors.neonCiano.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "NOVO RANKING!",
              style: TextStyle(
                color: AppColors.neonCiano,
                fontSize: 28,
                // CORREÇÃO: FontWeight.black não existe, use FontWeight.w900
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              icone,
              style: const TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 10),
            Text(
              "Parabéns! Você agora é nível",
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8), 
                fontSize: 16,
              ),
            ),
            Text(
              novoNivel.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonCiano,
                  foregroundColor: AppColors.backgroundEscuro,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  "CONTINUAR JORNADA",
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}