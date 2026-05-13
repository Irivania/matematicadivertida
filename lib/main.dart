import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Configurações e Temas
import 'core/config/firebase_options.dart'; 
import 'core/theme/app_colors.dart';

// Camada de Domínio (Interfaces)
import 'domain/repositories/i_auth_repository.dart';
import 'domain/repositories/i_ranking_repository.dart';

// Camada de Dados (Implementações e Serviços)
import 'data/services/auth_service.dart'; // Necessário para a injeção
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
        // 1. CORREÇÃO: Injeção do AuthService dentro do AuthRepositoryImpl
        Provider<IAuthRepository>(
          create: (_) => AuthRepositoryImpl(AuthService()),
        ),
        
        // 2. Repositório de Ranking
        Provider<IRankingRepository>(
          create: (_) => RankingRepositoryImpl(),
        ),
        
        // 3. Estado Global do Jogo
        ChangeNotifierProvider(
          create: (_) => GameState(),
        ),
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
        
        // Padronização de botões para o projeto
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.neonCiano,
            foregroundColor: Colors.black,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),

      // Tela inicial que decide entre Login ou Home
      home: const AuthWrapper(),

      // Configuração de Rotas
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute, 
    );
  }
}