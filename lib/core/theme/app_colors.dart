import 'package:flutter/material.dart';

class AppColors {
  // Fundo Principal (Dark para destacar o Neon)
  static const Color backgroundEscuro = Color(0xFF020617);
  static const Color backgroundCard = Color(0xFF0F172A);

  // Cores Neon - Modo Disputa
  static const Color neonCiano = Color(0xFF22D3EE);   // Para botões e HUD
  static const Color neonRosa = Color(0xFFEC4899);    // Para erros e alertas
  static const Color neonVerde = Color(0xFF4ADE80);   // Para acertos
  static const Color neonRoxo = Color(0xFF8B5CF6);    // Para títulos

  // Cores Amigáveis - Modo Treino (Mantendo a essência do seu projeto atual)
  static const Color treinoAzul = Color(0xFF3B82F6);
  static const Color treinoAmarelo = Color(0xFFFACC15);

  // Sombras de Brilho (Glow)
  static List<BoxShadow> glowCiano = [
    BoxShadow(
      color: neonCiano.withOpacity(0.5),
      blurRadius: 15,
      spreadRadius: 2,
    ),
  ];

  static List<BoxShadow> glowRosa = [
    BoxShadow(
      color: neonRosa.withOpacity(0.5),
      blurRadius: 15,
      spreadRadius: 2,
    ),
  ];
}