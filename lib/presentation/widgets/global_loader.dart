import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// CORREÇÃO: Usando caminhos absolutos baseados no seu projeto
import 'package:matematicadivertida/data/services/auth_service.dart';
import 'package:matematicadivertida/presentation/auth/login_screen.dart';
import 'package:matematicadivertida/presentation/screens/perfil_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Instanciando o serviço (ou usando Provider se preferir futuramente)
    final authService = AuthService();

    return StreamBuilder<User?>(
      // CORREÇÃO: O nome do getter no seu AuthService é 'usuarioStatus'
      stream: authService.usuarioStatus,
      builder: (context, snapshot) {
        // Estado de carregamento inicial
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator.adaptive()),
          );
        }

        // Se o snapshot tem dados, o usuário está autenticado
        if (snapshot.hasData && snapshot.data != null) {
          return const PerfilScreen();
        }

        // Caso contrário, redireciona para Login
        return const LoginScreen();
      },
    );
  }
}