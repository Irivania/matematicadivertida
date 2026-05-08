import 'package:flutter/material.dart';
import 'jogo_screen.dart';

class CriancaGame extends StatelessWidget {
  const CriancaGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: Colors.pinkAccent,
        scaffoldBackgroundColor: Colors.lightBlue.shade100,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 22, color: Colors.black),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pinkAccent,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      // ❌ Removido o "const" porque JogoScreen recebe parâmetro dinâmico
      child: JogoScreen(perfil: "crianca"),
    );
  }
}
