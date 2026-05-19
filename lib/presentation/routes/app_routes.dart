import 'package:flutter/material.dart';

// Imports de Telas usando caminhos absolutos seguros para Web
import 'package:matematicadivertida/presentation/screens/home_screen.dart';
import 'package:matematicadivertida/presentation/auth/cadastro_screen.dart'; 
import 'package:matematicadivertida/presentation/screens/perfil_screen.dart';
import 'package:matematicadivertida/presentation/screens/nivel_screen.dart';
import 'package:matematicadivertida/presentation/screens/trilha_screen.dart';
import 'package:matematicadivertida/presentation/screens/jogo_screen.dart';
import 'package:matematicadivertida/presentation/screens/ranking_screen.dart';
import 'package:matematicadivertida/presentation/screens/crianca_game.dart';
import 'package:matematicadivertida/presentation/screens/adulto_game.dart';
import 'package:matematicadivertida/presentation/screens/professor_game.dart';

// Imports de Autenticação
import 'package:matematicadivertida/presentation/auth/login_screen.dart'; 

class AppRoutes {
  // Constantes de Rota (Nomes Únicos)
  static const String login = "/"; 
  static const String cadastro = "/cadastro";
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
      login: (_) => const LoginScreen(),
      cadastro: (_) => const CadastroScreen(), 
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

  /// Gerador de rotas dinâmicas para parâmetros complexos ou extração de dados.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    // 1. Verifica se a rota chamada existe no mapa estático
    final builder = routes[settings.name];
    
    if (builder != null) {
      return MaterialPageRoute(
        settings: settings,
        builder: builder,
      );
    }

    // 2. Tratamento limpo e seguro de rotas dinâmicas (sem reflection/dynamic que quebra no Web)
    switch (settings.name) {
      case jogo:
        String perfilTexto = "crianca";

        // Extração baseada puramente em estruturas nativas estáveis
        if (settings.arguments is Map) {
          final argsMap = settings.arguments as Map;
          final rawPerfil = argsMap["perfil"];
          if (rawPerfil != null) {
            perfilTexto = rawPerfil.toString();
          }
        } else if (settings.arguments is String) {
          perfilTexto = settings.arguments as String;
        }

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => JogoScreen(perfil: perfilTexto),
        );
      
      // Fallback para rotas não encontradas
      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => Scaffold(
            body: Center(child: Text('Rota não encontrada: ${settings.name}')),
          ),
        );
    }
  }
}