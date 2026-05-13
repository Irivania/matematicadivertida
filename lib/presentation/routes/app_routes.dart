import 'package:flutter/material.dart';

// Imports de Telas (Screens)
import 'package:matematicadivertida/presentation/screens/home_screen.dart';
import 'package:matematicadivertida/presentation/screens/perfil_screen.dart';
import 'package:matematicadivertida/presentation/screens/nivel_screen.dart';
import 'package:matematicadivertida/presentation/screens/trilha_screen.dart';
import 'package:matematicadivertida/presentation/screens/jogo_screen.dart';

// IMPORTANTE: Se estes arquivos ainda não existem, mantenha os imports comentados
// para evitar erros de compilação globais no projeto.
/* 
import 'package:matematicadivertida/presentation/game/crianca_game.dart';
import 'package:matematicadivertida/presentation/game/adulto_game.dart';
import 'package:matematicadivertida/presentation/game/professor_game.dart';
*/

class AppRoutes {
  // Constantes de Rota
  static const String login = "/auth_login";
  static const String home = "/home_view";
  static const String perfil = "/perfil";
  static const String nivel = "/nivel";
  static const String trilha = "/trilha";
  static const String jogo = "/jogo";

  // Rotas de Modos de Jogo
  static const String crianca = "/crianca";
  static const String adulto = "/adulto";
  static const String professor = "/professor";

  /// Mapa de rotas estáticas para o MaterialApp
  static Map<String, WidgetBuilder> get routes {
    return {
      home: (_) => const HomeScreen(),
      perfil: (_) => const PerfilScreen(),
      nivel: (_) => const NivelScreen(),
      trilha: (_) => const TrilhaScreen(),

      // Registros dos Games - Substituídos temporariamente por JogoScreen 
      // para que o App compile enquanto os arquivos específicos não são criados.
      crianca: (_) => const JogoScreen(perfil: "crianca"),
      adulto: (_) => const JogoScreen(perfil: "adulto"),
      professor: (_) => const JogoScreen(perfil: "professor"),
    };
  }

  /// Gerador de rotas dinâmicas (essencial para passar argumentos para a JogoScreen)
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (settings.name == jogo) {
      // Recebe o argumento do perfil (ex: "crianca", "adulto")
      final args = settings.arguments as String? ?? "crianca";
      
      return MaterialPageRoute(
        builder: (_) => JogoScreen(perfil: args),
      );
    }
    
    // Se retornar null, o Flutter busca automaticamente no mapa 'routes' acima
    return null;
  }
}