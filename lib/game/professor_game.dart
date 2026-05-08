import 'package:flutter/material.dart';
import 'jogo_screen.dart';

class ProfessorGame extends StatelessWidget {
  const ProfessorGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: Colors.indigo,
        scaffoldBackgroundColor: Colors.brown.shade100,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 24, color: Colors.black87),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      // ❌ Removido o "const" porque JogoScreen recebe parâmetro dinâmico
      child: JogoScreen(perfil: "professor"),
    );
  }
}
