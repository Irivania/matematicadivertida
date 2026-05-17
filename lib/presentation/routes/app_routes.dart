import 'package:flutter/material.dart';

// Imports de Telas (Screens)
import '../screens/home_screen.dart';
import '../auth/cadastro_screen.dart'; // Importação oficial da sua tela de cadastro
import '../screens/perfil_screen.dart';
import '../screens/nivel_screen.dart';
import '../screens/trilha_screen.dart';
import '../screens/jogo_screen.dart';
import '../screens/ranking_screen.dart';
import '../screens/crianca_game.dart';
import '../screens/adulto_game.dart';
import '../screens/professor_game.dart';

// Imports de Autenticação
import '../auth/login_screen.dart'; 

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
      
      // CORRIGIDO: Agora aponta diretamente para a sua tela real criada!
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

  /// Gerador de rotas dinâmicas para parâmetros complexos ou animações.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
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