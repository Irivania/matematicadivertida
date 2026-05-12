import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/config/firebase_options.dart'; 
import 'core/theme/app_colors.dart';
import 'routes/app_routes.dart';

// Importação das Telas
import 'screens/auth/login_screen.dart';
import 'screens/perfil_screen.dart';
import 'screens/nivel_screen.dart';
import 'game/jogo_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  // 1. Garante a inicialização dos bindings do Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializa o Firebase com as configurações que corrigimos (Web/Android)
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
      // TEMA GLOBAL NEON
      // =================================================
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark, 
        scaffoldBackgroundColor: AppColors.backgroundEscuro,
        fontFamily: 'Roboto',
        
        // Estilo padrão para os botões do app
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
      // Definimos o Login como a primeira tela para garantir a autenticação
      initialRoute: '/login', 
      
      routes: {
        // Rota principal de Login
        '/login': (context) => const LoginScreen(),

        // Rotas dinâmicas baseadas no seu arquivo app_routes.dart
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.nivel: (context) => const NivelScreen(),
        
        // PROTEÇÃO EXTRA: Registramos a rota tanto pelo seu objeto AppRoutes 
        // quanto pela string direta '/perfil' para evitar erros de navegação.
        AppRoutes.perfil: (context) => const PerfilScreen(),
        '/perfil': (context) => const PerfilScreen(), 

        // Rota do Jogo com passagem de argumentos (Perfil escolhido)
        AppRoutes.jogo: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final String perfilEscolhido = (args is String) ? args : 'crianca';
          return JogoScreen(perfil: perfilEscolhido);
        },
      },
    );
  }
}