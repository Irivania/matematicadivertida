import 'package:flutter/material.dart';
import 'jogo_screen.dart';

class AdultoGame extends StatelessWidget {
  const AdultoGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey.shade900,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 24, color: Colors.white),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      // ❌ Removido o "const" porque JogoScreen recebe parâmetro dinâmico
      child: JogoScreen(perfil: "adulto"),
    );
  }
}
