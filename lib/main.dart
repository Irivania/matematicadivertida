import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

// CAMINHO CORRIGIDO: Apontando para o local real do arquivo dentro do seu projeto
import 'package:matematicadivertida/core/config/firebase_options.dart'; 

// Domínio e Dados
import 'package:matematicadivertida/data/services/auth_service.dart';
import 'package:matematicadivertida/data/repositories/auth_repository_impl.dart';
import 'package:matematicadivertida/domain/repositories/i_auth_repository.dart';
import 'package:matematicadivertida/presentation/controllers/auth_controller.dart';

// Apresentação (Mantendo 'screens' no plural conforme seu VS Code)
import 'package:matematicadivertida/presentation/auth/login_screen.dart';
import 'package:matematicadivertida/presentation/screens/perfil_screen.dart';

void main() async {
  // Garante a inicialização correta dos bindings do Flutter Web
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa o Firebase usando as opções do arquivo encontrado
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(
          create: (_) => AuthService(),
        ),
        ProxyProvider<AuthService, IAuthRepository>(
          update: (_, authService, __) => AuthRepositoryImpl(authService),
        ),
        ChangeNotifierProvider<AuthController>(
          create: (context) => AuthController(
            Provider.of<IAuthRepository>(context, listen: false),
          ),
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
      home: Consumer<AuthController>(
        builder: (context, authController, _) {
          
          // 1. Estado de Carregamento: Firebase checando o token em segundo plano
          if (authController.isLoading && authController.usuarioAtual == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // 2. Estado Autenticado: Usuário logado vai direto para a tela de Perfil
          if (authController.estaAutenticado) {
            return const PerfilScreen(); 
          }

          // 3. Estado Desautenticado: Exibe a tela de Login híbrida
          return const LoginScreen();
        },
      ),
    );
  }
}