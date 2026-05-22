// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:firebase_core/firebase_core.dart';

// Configuração do Firebase
import 'package:matematicadivertida/core/config/firebase_options.dart'; 

// Camada de Domain
import 'package:matematicadivertida/domain/repositories/i_auth_repository.dart';

// Camada de Data
import 'package:matematicadivertida/data/services/auth_service.dart';
import 'package:matematicadivertida/data/repositories/auth_repository_impl.dart';
import 'package:matematicadivertida/data/services/audio_voice_service.dart';
import 'package:matematicadivertida/data/models/game_state.dart'; 

// Camada de Presentation
import 'package:matematicadivertida/presentation/controllers/auth_controller.dart';
import 'package:matematicadivertida/presentation/controllers/jogo_controller.dart'; 
import 'package:matematicadivertida/presentation/auth/login_screen.dart';
import 'package:matematicadivertida/presentation/screens/home_screen.dart';
import 'package:matematicadivertida/presentation/routes/app_routes.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        // 1. Serviço Puro do Firebase Auth
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),

        // 2. Repositório
        ProxyProvider<AuthService, IAuthRepository>(
          update: (_, authService, __) => AuthRepositoryImpl(authService),
        ),

        // 3. Controlador de Autenticação
        ChangeNotifierProxyProvider<IAuthRepository, AuthController>(
          create: (context) => AuthController(context.read<IAuthRepository>()),
          update: (_, repository, controller) => controller ?? AuthController(repository),
        ),

        // 4. Serviço de Voz Antigo (Mantido para compatibilidade se outras telas usarem)
        ChangeNotifierProvider<AudioVoiceService>(
          create: (_) => AudioVoiceService(),
        ),

        // 5. Estado Global do Jogo
        ChangeNotifierProvider<GameState>(
          create: (_) => GameState(),
        ),

        // 6. Controlador Unificado do Jogo (Gerencia TTS e Microfone centralizados)
        ChangeNotifierProvider<JogoController>(
          create: (_) => JogoController(),
        ),
      ],
      child: const MeuApp(),
    ),
  );
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Matemática Divertida',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212), // Fundo escuro padrão caso as telas falhem
      ),
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: Consumer<AuthController>(
        builder: (context, authController, _) {
          
          if (authController.isLoading && authController.usuarioAtual == null) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan),
                ),
              ),
            );
          }

          if (authController.estaAutenticado) {
            return const HomeScreen(); 
          }

          return const LoginScreen();
        },
      ),
    );
  }
}