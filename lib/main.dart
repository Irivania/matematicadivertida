// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // <- Necessário para i18n
import 'package:matematicadivertida/l10n/app_localizations.dart'; // <- Caminho direto corrigido para o Web

// Configuração do Firebase
import 'package:matematicadivertida/core/config/firebase_options.dart';

// Camadas de Domain e Data
import 'package:matematicadivertida/domain/repositories/i_auth_repository.dart';
import 'package:matematicadivertida/data/services/auth_service.dart';
import 'package:matematicadivertida/data/repositories/auth_repository_impl.dart';
import 'package:matematicadivertida/data/models/game_state.dart';

// Camadas de Presentation (Controllers)
import 'package:matematicadivertida/presentation/controllers/auth_controller.dart';
import 'package:matematicadivertida/presentation/controllers/jogo_controller.dart';
import 'package:matematicadivertida/presentation/auth/login_screen.dart';
import 'package:matematicadivertida/presentation/screens/home_screen.dart';
import 'package:matematicadivertida/presentation/routes/app_routes.dart';

void main() async {
  // Garante que os bindings do Flutter estejam prontos
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicialização do Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        // 1. Serviço de Autenticação
        Provider<AuthService>(create: (_) => AuthService()),

        // 2. Repositório de Auth
        ProxyProvider<AuthService, IAuthRepository>(
          update: (_, authService, __) => AuthRepositoryImpl(authService),
        ),

        // 3. Controlador de Autenticação
        ChangeNotifierProxyProvider<IAuthRepository, AuthController>(
          create: (context) => AuthController(context.read<IAuthRepository>()),
          update: (_, repository, controller) => controller ?? AuthController(repository),
        ),

        // 4. Estado Global do Jogo (Score, Nível, etc)
        ChangeNotifierProvider<GameState>(create: (_) => GameState()),

        // 5. Controlador Unificado do Jogo e Voz (TTS e Microfone)
        ChangeNotifierProvider<JogoController>(create: (_) => JogoController()),
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
      
      // CONFIGURAÇÕES DE INTERNACIONALIZAÇÃO (i18n) CONECTADAS AO GAMESTATE:
      locale: context.watch<GameState>().currentLocale, // <- Controla o idioma dinamicamente
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.cyan,
      ),
      // Uso da navegação dinâmica que você já configurou
      onGenerateRoute: AppRoutes.onGenerateRoute,
      home: Consumer<AuthController>(
        builder: (context, authController, _) {
          // Exibe loader enquanto verifica o estado da sessão
          if (authController.isLoading && authController.usuarioAtual == null) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan),
                ),
              ),
            );
          }

          // Rota inicial baseada no status de autenticação
          if (authController.estaAutenticado) {
            return const HomeScreen();
          }

          return const LoginScreen();
        },
      ),
    );
  }
}