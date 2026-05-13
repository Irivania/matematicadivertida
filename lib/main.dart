// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Configurações e Temas
import 'core/config/firebase_options.dart'; 
import 'core/theme/app_colors.dart';

// Camada de Domínio (Interfaces)
import 'domain/repositories/i_auth_repository.dart';
import 'domain/repositories/i_ranking_repository.dart';

// Camada de Dados (Implementações)
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/ranking_repository_impl.dart';
import 'data/models/game_state.dart'; 

// Camada de Apresentação
import 'presentation/auth/auth_wrapper.dart';
import 'presentation/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Erro crítico de inicialização: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        // 1. AJUSTE: Injetar usando a Interface (IAuthRepository)
        Provider<IAuthRepository>(
          create: (_) => AuthRepositoryImpl(),
        ),
        // 2. ADIÇÃO: Injetar o Repositório de Ranking
        Provider<IRankingRepository>(
          create: (_) => RankingRepositoryImpl(),
        ),
        // 3. ESTADO: GameState permanece como ChangeNotifier
        ChangeNotifierProvider(create: (_) => GameState()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Matemática Divertida',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.neonCiano,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppColors.backgroundEscuro,
        fontFamily: 'Roboto',
        
        // ... (Seu DialogTheme e ElevatedButtonTheme estão perfeitos, mantê-los aqui)
      ),

      home: const AuthWrapper(),

      // 4. AJUSTE: Corrigindo o nome do método para coincidir com AppRoutes
      routes: AppRoutes.routes, // Adicionado para suportar pushNamed simples
      onGenerateRoute: AppRoutes.onGenerateRoute, 
    );
  }
}