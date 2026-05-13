import 'package:flutter/material.dart';
// CORREÇÃO: Importando o caminho absoluto da tela de jogo
import 'package:matematicadivertida/presentation/screens/jogo_screen.dart';

class AdultoGame extends StatelessWidget {
  const AdultoGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: Brightness.dark, // Define o tema como escuro globalmente
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xFF121212), // Cinza quase preto padrão 2026
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 24, color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      // Agora o compilador reconhece o JogoScreen através do import absoluto
      child: const JogoScreen(perfil: "adulto"),
    );
  }
}