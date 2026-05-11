import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart'; // Verifique se o caminho está correto após mover o arquivo
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _estaCarregando = false;

  // Função para lidar com o Login do Google
  void _fazerLoginGoogle() async {
    setState(() => _estaCarregando = true);

    bool sucesso = await _authService.entrarComGoogle();

    setState(() => _estaCarregando = false);

    if (sucesso) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/perfil');
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ops! O login com Google falhou ou foi cancelado."),
          backgroundColor: AppColors.neonRosa,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundEscuro,
      body: Stack(
        children: [
          // FUNDO: Verifique se renomeou o arquivo na pasta assets/images para remover o .png extra
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/fundo_login_neon.png'),
                fit: BoxFit.cover,
                opacity: 0.3,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // MASCOTE: Verifique se renomeou para remover o .png extra
                  Image.asset('assets/images/mascote_cal3.png', height: 180),
                  const SizedBox(height: 20),
                  const Text(
                    "MATEMÁTICA DIVERTIDA",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.neonCiano,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: AppColors.neonCiano, blurRadius: 15)],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Sua aventura matemática começa aqui!",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 50),

                  // BOTÃO CORRIGIDO: Trocamos o Image.network (SVG) por um Icon nativo
                  _estaCarregando
                      ? const CircularProgressIndicator(color: AppColors.neonCiano)
                      : SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: OutlinedButton.icon(
                            onPressed: _fazerLoginGoogle,
                            icon: const Icon(
                              Icons.account_circle, // Ícone seguro que não causa erro de codec
                              color: Colors.white,
                              size: 28,
                            ),
                            label: const Text(
                              "ENTRAR COM GOOGLE",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: AppColors.neonCiano, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              backgroundColor: AppColors.backgroundCard.withOpacity(0.5),
                            ),
                          ),
                        ),
                  
                  const SizedBox(height: 20),
                  const Text(
                    "Seguro • Rápido • Grátis",
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}