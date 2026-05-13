import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/auth_controller.dart'; // Ajuste conforme seu provider
import '../pages/login_page.dart';
import '../pages/register_page.dart';

/// O AuthGuard decide qual tela exibir baseado no estado global de autenticação.
class AuthGuard extends ConsumerWidget {
  final Widget authenticatedRoute;

  const AuthGuard({super.key, required this.authenticatedRoute});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        // 1. Caso não esteja logado, vai para o Login
        if (user == null) {
          return const LoginPage();
        }
        
        // 2. Segurança Enterprise: Validação de e-mail obrigatória
        if (!user.emailVerified) {
          return const VerifyEmailPage(); // Tela simples pedindo check no e-mail
        }

        // 3. Usuário autenticado e verificado
        return authenticatedRoute;
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => const LoginPage(),
    );
  }
}

/// Tela de suporte para e-mail não verificado
class VerifyEmailPage extends ConsumerWidget {
  const VerifyEmailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      app_bar: AppBar(title: const Text("Verifique seu E-mail")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mark_email_unread_outlined, size: 80),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("Enviamos um link de confirmação. Por favor, verifique sua caixa de entrada."),
            ),
            ElevatedButton(
              onPressed: () => ref.read(authRepositoryProvider).logout(),
              child: const Text("Voltar para o Login"),
            ),
          ],
        ),
      ),
    );
  }
}