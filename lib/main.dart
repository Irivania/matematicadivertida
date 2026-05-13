import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Importações Core e Configurações
import 'core/config/firebase_options.dart'; 
import 'core/theme/app_colors.dart';

// Importações de Camadas e Modelos (Caminhos ajustados para evitar erros de URI)
import 'data/models/game_state.dart'; 
import 'presentation/auth/auth_wrapper.dart';
import 'presentation/routes/app_routes.dart';
import 'presentation/screens/jogo_screen.dart'; // Verifique se este caminho existe
import 'presentation/screens/trilha_screen.dart';

void main() async {
  // 1. Garante a inicialização dos bindings do Flutter antes do Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializa o Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    // 3. Gerenciamento de Estado Global
    MultiProvider(
      providers: [
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

      // =================================================
      // TEMA GLOBAL NEON
      // =================================================
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark, 
        scaffoldBackgroundColor: AppColors.backgroundEscuro,
        fontFamily: 'Roboto',
        
        // CORREÇÃO: Usando DialogThemeData em vez de DialogTheme
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.backgroundEscuro,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: const BorderSide(color: AppColors.neonCiano, width: 1),
          ),
        ),

        // Botões Neon com sintaxe atualizada
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.neonCiano,
            foregroundColor: AppColors.backgroundEscuro,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 12,
            // CORREÇÃO: Sugestão de uso de transparência compatível
            shadowColor: AppColors.neonCiano.withValues(alpha: 0.8),
          ),
        ),
      ),

      // Ponto de entrada que decide se vai para Login ou Perfil
      home: const AuthWrapper(),

      // =================================================
      // MAPA DE ROTAS
      // =================================================
      routes: {
        // Rotas estáticas
        ...AppRoutes.routes,
        AppRoutes.trilha: (context) => const TrilhaScreen(),

        // Rota dinâmica para o Jogo
        AppRoutes.jogo: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          
          // Tenta ler o perfil dos argumentos ou do estado global
          // Certifique-se que o getter 'perfilEscolhido' ou similar existe no GameState
          final String perfilEscolhido = (args is String) 
              ? args 
              : context.read<GameState>().perfilUsuario ?? 'crianca'; 
          
          return JogoScreen(perfil: perfilEscolhido);
        },
      },
    );
  }
}