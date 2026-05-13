import 'package:flutter/material.dart';
import 'package:matematicadivertida/core/theme/app_colors.dart';

/// Um botão estilizado para representar as opções de resposta no jogo.
class RespostaButton extends StatelessWidget {
  final String texto;
  final VoidCallback onTap;

  const RespostaButton({
    super.key,
    required this.texto,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              // CORREÇÃO: Atualizado de withOpacity para withValues para evitar avisos
              border: Border.all(
                color: AppColors.neonCiano.withValues(alpha: 0.5),
              ),
              gradient: LinearGradient(
                colors: [
                  AppColors.neonCiano.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    texto,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.neonCiano,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}