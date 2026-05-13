import 'package:flutter/material.dart';
import 'package:matematicadivertida/data/services/auth_service.dart';
import 'package:matematicadivertida/presentation/routes/app_routes.dart';
import 'package:matematicadivertida/core/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Inicialização das variáveis que o analyze deu erro
  final AuthService _authService = AuthService();
  bool _estaCarregando = false;

  /// Método de login que você enviou, agora integrado corretamente à classe
  void _fazerLoginGoogle() async {
    setState(() => _estaCarregando = true);

    try {
      // Tenta realizar a autenticação
      final credential = await _authService.entrarComGoogle();
      final bool sucesso = credential != null;

      // Pausa estratégica para evitar bugs de transição no Web/Mobile
      await Future.delayed(const Duration(milliseconds: 600));

      if (sucesso) {
        if (!mounted) return;
        setState(() => _estaCarregando = false);
        
        // Se deu certo, vai para a tela de seleção de perfil
        Navigator.pushReplacementNamed(context, AppRoutes.perfil);
      } else {
        if (!mounted) return;
        setState(() => _estaCarregando = false);
        _mostrarErro("O login foi cancelado ou falhou. Tente novamente!");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _estaCarregando = false);
      _mostrarErro("Erro ao autenticar. Verifique sua conexão.");
    }
  }

  /// Método auxiliar para exibir o SnackBar de erro
  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundEscuro,
      body: Center(
        child: _estaCarregando
            ? const CircularProgressIndicator(color: AppColors.neonCiano)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calculate, size: 80, color: AppColors.neonCiano),
                  const SizedBox(height: 20),
                  const Text(
                    "Matemática Divertida",
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.login),
                    label: const Text("ENTRAR COM GOOGLE"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.neonCiano,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    onPressed: _fazerLoginGoogle,
                  ),
                ],
              ),
      ),
    );
  }
}