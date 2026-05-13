import 'package:flutter/material.dart';
// CORREÇÃO: Caminho absoluto para resolver o erro de URI
import 'package:matematicadivertida/presentation/screens/jogo_screen.dart';

class CriancaGame extends StatelessWidget {
  const CriancaGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        brightness: Brightness.light, // Define o tema como claro para o perfil infantil
        primaryColor: Colors.pinkAccent,
        scaffoldBackgroundColor: const Color(0xFFE3F2FD), // Um azul claro mais moderno
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontSize: 22, 
            color: Colors.black87,
            fontWeight: FontWeight.bold, // Deixa o texto mais legível para crianças
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pinkAccent,
            foregroundColor: Colors.white,
            elevation: 5,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25), // Botões mais arredondados/amigáveis
            ),
          ),
        ),
      ),
      // Com o import corrigido, o erro 'JogoScreen isn't defined' desaparece
      child: const JogoScreen(perfil: "crianca"),
    );
  }
}