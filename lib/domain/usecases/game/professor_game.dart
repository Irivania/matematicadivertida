import 'package:flutter/material.dart';
// CORREÇÃO: Importação absoluta para resolver o erro de URI e reconhecimento do Widget
import 'package:matematicadivertida/presentation/screens/jogo_screen.dart';

class ProfessorGame extends StatelessWidget {
  const ProfessorGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.indigo,
        // Um tom de "papel" ou "pergaminho" mais profissional para o ambiente acadêmico
        scaffoldBackgroundColor: const Color(0xFFF5F5DC), 
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontSize: 24, 
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.w600,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            elevation: 3,
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Bordas mais retas para um visual sóbrio
            ),
          ),
        ),
      ),
      // Com o import corrigido, o erro 'JogoScreen isn't defined' é resolvido
      child: const JogoScreen(perfil: "professor"),
    );
  }
}