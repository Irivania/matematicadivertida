// lib/presentation/screens/crianca_game.dart

import 'package:flutter/material.dart';
import 'package:matematicadivertida/presentation/screens/jogo_screen.dart';

/// Wrapper de Tema para a experiência de usuário Infantil.
/// 
/// Diferente da versão adulta, aqui usamos cores vibrantes e formas 
/// arredondadas (Pills) para transmitir segurança e diversão.
class CriancaGame extends StatelessWidget {
  const CriancaGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _buildChildTheme(),
      child: const JogoScreen(perfil: "crianca"),
    );
  }

  ThemeData _buildChildTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Esquema de cores lúdico baseado em Azul Moderno e Rosa Vibrante
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.pinkAccent,
        brightness: Brightness.light,
        surface: const Color(0xFFE3F2FD), // Azul clarinho moderno
        primary: Colors.pinkAccent,
        secondary: Colors.orangeAccent, // Cor de destaque para bônus/estrelas
      ),
      
      scaffoldBackgroundColor: const Color(0xFFE3F2FD),

      // Tipografia amigável e legível para alfabetização
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          fontSize: 22, 
          color: Colors.black87,
          fontWeight: FontWeight.bold,
          fontFamily: 'ComicSans', // Opcional: ou uma fonte arredondada padrão
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w900,
          color: Colors.blueAccent,
        ),
      ),

      // Botões estilo "Pill" (padrão de jogos mobile infantis)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pinkAccent,
          foregroundColor: Colors.white,
          elevation: 6,
          shadowColor: Colors.pinkAccent.withValues(alpha: 0.4),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          shape: const StadiumBorder(), // Botão totalmente arredondado nas pontas
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}