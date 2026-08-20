// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; 
import 'package:matematicadivertida/l10n/app_localizations.dart'; 

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
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        ProxyProvider<AuthService, IAuthRepository>(
          update: (_, authService, __) => AuthRepositoryImpl(authService),
        ),
        ChangeNotifierProxyProvider<IAuthRepository, AuthController>(
          create: (context) => AuthController(context.read<IAuthRepository>()),
          update: (_, repository, controller) => controller ?? AuthController(repository),
        ),
        ChangeNotifierProvider<GameState>(create: (_) => GameState()),
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
    // Escuta o GameState para capturar a alteração de idioma globalmente
    final gs = context.watch<GameState>();

    return MaterialApp(
      key: ValueKey(gs.currentLocale), // <--- ESSENCIAL: Força a recriação do app ao mudar o idioma
      title: 'Matemática Divertida',
      debugShowCheckedModeBanner: false,
      
      locale: gs.currentLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.cyan,
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