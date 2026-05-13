import 'package:flutter/material.dart';

// Imports de Telas (Screens)
import '../screens/home_screen.dart';
import '../screens/perfil_screen.dart';
import '../screens/nivel_screen.dart';
import '../screens/trilha_screen.dart';
import '../screens/jogo_screen.dart';
import '../screens/ranking_screen.dart';
import '../screens/crianca_game.dart';
import '../screens/adulto_game.dart';
import '../screens/professor_game.dart';

// Importante: Se você tiver uma tela de Login específica, importe-a aqui.
// Caso contrário, redirecionamos para a Home ou criamos o placeholder.

class AppRoutes {
  // Constantes de Rota (Nomes Únicos)
  static const String login = "/"; // Definida como rota inicial para resolver erro na PerfilScreen
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
  static Map<String, WidgetBuilder> get routes {
    return {
      // Se não tiver uma LoginScreen separada, a home assume o papel inicial
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

  /// Gerador de rotas dinâmicas para parâmetros complexos ou animações.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        // Caso use a HomeScreen como tela de entrada/login
        return MaterialPageRoute(builder: (_) => const HomeScreen());
        
      case jogo:
        // Permite chamar JogoScreen diretamente passando o perfil como argumento
        final args = settings.arguments as String? ?? "crianca";
        return MaterialPageRoute(
          builder: (_) => JogoScreen(perfil: args),
        );
      
      // Fallback para rotas não encontradas
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Rota não encontrada')),
          ),
        );
    }
  }
}