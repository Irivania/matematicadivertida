import 'package:flutter/material.dart';

class AppColors {
  // Cores constantes (podem ser usadas em qualquer lugar)
  static const Color backgroundEscuro = Color(0xFF0D0D0D);
  static const Color neonCiano = Color(0xFF00FFFF);
  static const Color neonRosa = Color(0xFFFF00FF);
  static const Color neonRoxo = Color(0xFF9D00FF);
  static const Color brancoPuro = Color(0xFFFFFFFF);
  
  // Adicionando as cores que o seu log de erros disse que estavam faltando:
  static const Color neonVerde = Color(0xFF39FF14);
  static const Color neonAmarelo = Color(0xFFFFFF00);
  static const Color backgroundCard = Color(0xFF1E1E1E);

  // Cores dinâmicas (NÃO podem usar 'const' antes delas nos widgets)
  // O uso de 'static Color get' é mais eficiente para 2026
  static Color get cianoBrilhante => neonCiano.withValues(alpha: 0.8);
  static Color get rosaSombra => neonRosa.withValues(alpha: 0.2);
}