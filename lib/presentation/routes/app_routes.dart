// lib/presentation/routes/app_routes.dart

import 'package:flutter/material.dart';

// Imports de Telas (Screens)
import 'package:matematicadivertida/presentation/screens/home_screen.dart';
import 'package:matematicadivertida/presentation/screens/perfil_screen.dart';
import 'package:matematicadivertida/presentation/screens/nivel_screen.dart';
import 'package:matematicadivertida/presentation/screens/trilha_screen.dart';
import 'package:matematicadivertida/presentation/screens/jogo_screen.dart';
import 'package:matematicadivertida/presentation/screens/ranking_screen.dart';

// Agora com os códigos completos, os imports estão liberados
import 'package:matematicadivertida/presentation/screens/crianca_game.dart';
import 'package:matematicadivertida/presentation/screens/adulto_game.dart';
import 'package:matematicadivertida/presentation/screens/professor_game.dart';

class AppRoutes {
  // Constantes de Rota (Nomes Únicos)
  static const String home = "/home_view";
  static const String perfil = "/perfil";
  static const String nivel = "/nivel";
  static const String trilha = "/trilha";
  static const String jogo = "/jogo";
  static const String ranking = "/ranking";

  // Rotas de Modos de Jogo Específicos
  static const String crianca = "/modo_crianca";
  static const String adulto = "/modo_adulto";
  static const String professor = "/modo_professor";

  /// Mapa de rotas estáticas.
  /// Em 2026, usamos este mapa para telas sem argumentos complexos.
  static Map<String, WidgetBuilder> get routes {
    return {
      home: (_) => const HomeScreen(),
      perfil: (_) => const PerfilScreen(),
      nivel: (_) => const NivelScreen(),
      trilha: (_) => const TrilhaScreen(),
      ranking: (_) => const RankingScreen(),

      // Widgets de Tema/Contexto que encapsulam a JogoScreen
      crianca: (_) => const CriancaGame(),
      adulto: (_) => const AdultoGame(),
      professor: (_) => const ProfessorGame(),
    };
  }

  /// Gerador de rotas dinâmicas.
  /// Essencial para passar parâmetros ou definir animações customizadas.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case jogo:
        // Permite chamar JogoScreen diretamente passando o perfil como argumento
        final args = settings.arguments as String? ?? "crianca";
        return MaterialPageRoute(
          builder: (_) => JogoScreen(perfil: args),
        );
      
      // Fallback para rotas não encontradas (404 Error Screen em 2026)
      default:
        return null;
    }
  }
}