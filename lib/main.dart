import 'package:flutter/material.dart';
import 'routes/app_routes.dart';

// Telas principais
import 'screens/home_screen.dart';
import 'screens/perfil_screen.dart';   // ✅ nome correto
import 'screens/nivel_screen.dart';

// Telas de jogo
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
      title: 'Matemática Divertida',
      debugShowCheckedModeBanner: false,

      // 🎨 Tema global
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

      // ✅ Rota inicial
      initialRoute: AppRoutes.home,

      // ✅ Rotas do app
      routes: {
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.perfil: (context) => const PerfilScreen(),
        AppRoutes.nivel: (context) => const NivelScreen(),

        // 🎮 Perfis de jogo
        AppRoutes.jogo: (context) => JogoScreen(perfil: "crianca"), // ❌ sem const
        AppRoutes.crianca: (context) => const CriancaGame(),
        AppRoutes.adulto: (context) => const AdultoGame(),
        AppRoutes.professor: (context) => const ProfessorGame(),
      },
    );
  }
}
