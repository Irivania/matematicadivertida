import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PerguntaCard extends StatelessWidget {
  final String enunciado;

  const PerguntaCard({super.key, required this.enunciado});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundEscuro.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.neonCiano, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCiano.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Text(
        enunciado,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}