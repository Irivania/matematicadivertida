import 'package:flutter/material.dart';

// Telas principais
import '../screens/home_screen.dart';
import '../screens/perfil_screen.dart';
import '../screens/nivel_screen.dart';

// Telas de jogo
import '../game/jogo_screen.dart';
import '../game/crianca_game.dart';
import '../game/adulto_game.dart';
import '../game/professor_game.dart';

class AppRoutes {
  // ✅ Constantes de rotas
  static const home = "/";
  static const perfil = "/perfil";
  static const nivel = "/nivel";
  static const jogo = "/jogo";

  // 🎮 Rotas específicas para cada perfil
  static const crianca = "/crianca";
  static const adulto = "/adulto";
  static const professor = "/professor";

  // ✅ Mapa de rotas
  static final routes = {
    home: (_) => const HomeScreen(),
    perfil: (_) => const PerfilScreen(),
    nivel: (_) => const NivelScreen(),
    jogo: (_) => JogoScreen(perfil: "crianca"), // ❌ sem const porque recebe parâmetro

    // Perfis de jogo
    crianca: (_) => const CriancaGame(),
    adulto: (_) => const AdultoGame(),
    professor: (_) => const ProfessorGame(),
  };
}
