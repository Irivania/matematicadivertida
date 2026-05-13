import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// 1. Uso de caminhos absolutos (package:...) para garantir que o compilador encontre os arquivos
import 'package:matematicadivertida/data/services/auth_service.dart';
import 'package:matematicadivertida/presentation/auth/login_screen.dart';
import 'package:matematicadivertida/presentation/screens/perfil_screen.dart';

/// [AuthWrapper] atua como o "Zelador" ou "Gatekeeper" do aplicativo.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Certifique-se que o AuthService possui o getter 'usuarioStatus'
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.usuarioStatus,
      builder: (context, snapshot) {
        // Tratamento de Estado de Conexão:
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0D0D0D), // Cor de fundo padrão para evitar flash branco
            body: Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          );
        }

        // Lógica de Roteamento Reativo:
        if (snapshot.hasData && snapshot.data != null) {
          // Garanta que PerfilScreen esteja definida como uma Classe (Widget)
          return const PerfilScreen();
        }

        // Se o snapshot for nulo, o usuário não está autenticado.
        return const LoginScreen();
      },
    );
  }
}