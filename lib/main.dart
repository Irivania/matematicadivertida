import 'package:flutter/material.dart';
import 'routes/app_routes.dart';

// Telas Principais
import 'screens/home_screen.dart';
import 'screens/perfil_screen.dart';
import 'screens/nivel_screen.dart';

// Jogo Unificado
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

      // =================================================
      // TEMA GLOBAL (Material 3)
      // =================================================
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFDFDFD),
        
        // Padronização das AppBars
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.black,
        ),

        // Padronização dos Botões para todo o App
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
      // GERENCIAMENTO DE ROTAS
      // =================================================
      initialRoute: AppRoutes.home,
      routes: {
        // Tela inicial de Boas-vindas
        AppRoutes.home: (context) => const HomeScreen(),

        // Seleção de Perfil (Criança, Adulto, Professor)
        AppRoutes.perfil: (context) => const PerfilScreen(),

        // Tela de Nível (Opcional, conforme seu fluxo)
        AppRoutes.nivel: (context) => const NivelScreen(),

        // Jogo Principal Unificado
        AppRoutes.jogo: (context) {
          // Captura o argumento do perfil enviado pela PerfilScreen
          final args = ModalRoute.of(context)?.settings.arguments;
          
          // Tratamento de segurança: se não vier nada, assume 'crianca'
          final String perfilEscolhido = (args is String) ? args : 'crianca';

          return JogoScreen(
            perfil: perfilEscolhido,
          );
        },
      },
    );
  }
}