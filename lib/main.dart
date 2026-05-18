import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

// Configuração do Firebase
import 'package:matematicadivertida/core/config/firebase_options.dart'; 

// Camada de Domain (Contratos de Repositório)
import 'package:matematicadivertida/domain/repositories/i_auth_repository.dart';

// Camada de Data (Serviços e Implementações)
import 'package:matematicadivertida/data/services/auth_service.dart';
import 'package:matematicadivertida/data/repositories/auth_repository_impl.dart';
import 'package:matematicadivertida/data/services/audio_voice_service.dart';

// Camada de Presentation (Controladores, Telas e Rotas)
import 'package:matematicadivertida/presentation/controllers/auth_controller.dart';
import 'package:matematicadivertida/presentation/auth/login_screen.dart';
import 'package:matematicadivertida/presentation/auth/cadastro_screen.dart';
import 'package:matematicadivertida/presentation/screens/perfil_screen.dart';
import 'package:matematicadivertida/presentation/screens/home_screen.dart'; 
import 'package:matematicadivertida/presentation/routes/app_routes.dart'; 

void main() async {
  // Garante a inicialização correta dos bindings do Flutter antes de rodar os serviços
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa o Firebase usando as opções do arquivo configurado
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

        // 2. Repositório que depende do AuthService (Injeção via ProxyProvider)
        ProxyProvider<AuthService, IAuthRepository>(
          update: (_, authService, __) => AuthRepositoryImpl(authService),
        ),

        // 3. Controlador de Estado de Autenticação reativo às mudanças do Repositório
        ChangeNotifierProxyProvider<IAuthRepository, AuthController>(
          create: (context) => AuthController(context.read<IAuthRepository>()),
          update: (_, repository, controller) => controller ?? AuthController(repository),
        ),

        // 4. Provedor do Serviço de Voz (Garante acesso ao TTS e STT globalmente)
        ChangeNotifierProvider<AudioVoiceService>(
          create: (_) => AudioVoiceService(),
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
      ),
      
      // 🗺️ Tabela de Rotas Nomeadas do Aplicativo
      routes: {
        // 🚨 CORRIGIDO: A linha do AppRoutes.login foi removida daqui!
        // Como o parâmetro 'home' abaixo já renderiza a LoginScreen(), 
        // mantê-la aqui gerava duplicidade com a rota padrão '/' e causava a tela vermelha.
        
        AppRoutes.cadastro: (context) => const CadastroScreen(),
        AppRoutes.perfil: (context) => const PerfilScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
      },

      // ✅ O Consumer decide de forma limpa qual é a tela inicial do app, sem conflitos
      home: Consumer<AuthController>(
        builder: (context, authController, _) {
          
          // 1. Estado de Carregamento: Firebase checando o token em segundo plano
          if (authController.isLoading && authController.usuarioAtual == null) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan),
                ),
              ),
            );
          }

          // 2. Estado Autenticado: Usuário logado vai direto para a tela de Perfil para escolher o avatar
          if (authController.estaAutenticado) {
            return const PerfilScreen(); 
          }

          // 3. Estado Desautenticado: Exibe a tela de Login por padrão
          return const LoginScreen();
        },
      ),
    );
  }
}