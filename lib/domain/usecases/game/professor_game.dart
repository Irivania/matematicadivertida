// lib/presentation/screens/professor_game.dart

import 'package:flutter/material.dart';
import 'package:matematicadivertida/presentation/screens/jogo_screen.dart';

/// Wrapper de Tema para a experiência de usuário do Professor.
/// 
/// Este perfil utiliza tons de Indigo e Bege (Beige/Off-white) para 
/// reduzir a fadiga visual e transmitir uma estética de "Dashboard" educacional.
class ProfessorGame extends StatelessWidget {
  const ProfessorGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _buildProfessorTheme(),
      child: const JogoScreen(perfil: "professor"),
    );
  }

  ThemeData _buildProfessorTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Esquema de cores: Indigo Acadêmico e tons de areia
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.indigo,
        brightness: Brightness.light,
        surface: const Color(0xFFF5F5DC), // Tom Bege/Pergaminho
        primary: Colors.indigo,
        onSurface: const Color(0xFF2C3E50), // Azul escuro para textos
      ),
      
      scaffoldBackgroundColor: const Color(0xFFF5F5DC),

      // Tipografia clássica e legível
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          fontSize: 22, 
          color: Color(0xFF2C3E50),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
        headlineMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
      ),

      // Botões com bordas mais geométricas (Sóbrio)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Bordas menos arredondadas que a criança
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Personalização de inputs para o perfil professor (mais clean)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.indigo),
        ),
      ),
    );
  }
}