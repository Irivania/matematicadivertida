import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/config/firebase_options.dart'; // Certifique-se que este arquivo existe!
import 'core/theme/app_colors.dart';
import 'routes/app_routes.dart';

// Telas
import 'screens/auth/login_screen.dart';
import 'screens/perfil_screen.dart';
import 'screens/nivel_screen.dart';
import 'game/jogo_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  // 1. Essencial para o Firebase funcionar
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializa o Firebase (Windows, Web ou Mobile)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Matemática Divertida',
      debugShowCheckedModeBanner: false,

      // =================================================
      // TEMA GLOBAL NEON (Atualizado para o Modo Disputa)
      // =================================================
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark, // Ativa o modo escuro global
        scaffoldBackgroundColor: AppColors.backgroundEscuro,
        fontFamily: 'Roboto',
        
        // Estilização dos Botões Globais
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.neonCiano,
            foregroundColor: AppColors.backgroundEscuro,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
        ),
      ),

      // =================================================
      // GERENCIAMENTO DE ROTAS
      // =================================================
      // Mudamos a rota inicial para a LoginScreen para capturar o ID Único
      initialRoute: '/login', 
      
      routes: {
        // Nova Rota de Login
        '/login': (context) => const LoginScreen(),

        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.perfil: (context) => const PerfilScreen(),
        AppRoutes.nivel: (context) => const NivelScreen(),

        AppRoutes.jogo: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final String perfilEscolhido = (args is String) ? args : 'crianca';
          return JogoScreen(perfil: perfilEscolhido);
        },
      },
    );
  }
}