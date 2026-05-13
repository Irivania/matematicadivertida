// lib/presentation/screens/adulto_game.dart

import 'package:flutter/material.dart';
import 'package:matematicadivertida/presentation/screens/jogo_screen.dart';

/// Wrapper de Tema para a experiência de usuário Adulta.
/// 
/// Em 2026, evitamos instanciar ThemeData dentro do build para não gerar
/// novos objetos de tema em cada rebuild. O ideal é usar constantes ou 
/// extrair para um arquivo de tema dedicado.
class AdultoGame extends StatelessWidget {
  const AdultoGame({super.key});

  @override
  Widget build(BuildContext context) {
    // Definimos o tema específico para adultos aqui.
    // Isso garante que a JogoScreen herde o visual mais sóbrio/profissional.
    return Theme(
      data: _buildAdultTheme(),
      child: const JogoScreen(perfil: "adulto"),
    );
  }

  ThemeData _buildAdultTheme() {
    return ThemeData(
      useMaterial3: true, // Garante suporte aos novos componentes do Flutter 2026
      brightness: Brightness.dark,
      primaryColor: Colors.deepPurple,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.deepPurple,
        brightness: Brightness.dark,
        surface: const Color(0xFF121212),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      
      // Padronização tipográfica para acessibilidade adulta
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          fontSize: 20, 
          color: Colors.white, 
          letterSpacing: 0.5,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Estilização global de botões para este contexto
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}