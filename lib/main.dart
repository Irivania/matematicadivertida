import 'package:flutter/material.dart';
import 'routes/app_routes.dart';

// =====================================================
// TELAS PRINCIPAIS
// =====================================================

import 'screens/home_screen.dart';
import 'screens/perfil_screen.dart';
import 'screens/nivel_screen.dart';

// =====================================================
// TELAS DE JOGO
// =====================================================

import 'game/crianca_game.dart';
import 'game/adulto_game.dart';
import 'game/professor_game.dart';
import 'game/jogo_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      // =================================================
      // CONFIGURAÇÕES GERAIS
      // =================================================

      title: 'Matemática Divertida',

      debugShowCheckedModeBanner: false,

      // =================================================
      // TEMA
      // =================================================

      theme: ThemeData(
        useMaterial3: true,

        fontFamily: 'Roboto',

        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.light,
        ),

        scaffoldBackgroundColor: const Color(0xFFFDFDFD),

        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 14,
            ),

            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
      ),

      // =================================================
      // ROTA INICIAL
      // =================================================

      initialRoute: AppRoutes.home,

      // =================================================
      // ROTAS
      // =================================================

      routes: {

        // =============================================
        // HOME
        // =============================================

        AppRoutes.home: (context) =>
            const HomeScreen(),

        // =============================================
        // PERFIL
        // =============================================

        AppRoutes.perfil: (context) =>
            const PerfilScreen(),

        // =============================================
        // NÍVEL
        // (Pode remover depois se não usar)
        // =============================================

        AppRoutes.nivel: (context) =>
            const NivelScreen(),

        // =============================================
        // JOGO PRINCIPAL
        // =============================================

        AppRoutes.jogo: (context) {

          // 🔥 RECEBE O PERFIL ESCOLHIDO
          final perfil =
              ModalRoute.of(context)!
                  .settings
                  .arguments as String;

          return JogoScreen(
            perfil: perfil,
          );
        },

        // =============================================
        // TELAS ANTIGAS (Opcional)
        // =============================================

        AppRoutes.crianca: (context) =>
            const CriancaGame(),

        AppRoutes.adulto: (context) =>
            const AdultoGame(),

        AppRoutes.professor: (context) =>
            const ProfessorGame(),
      },
    );
  }
}