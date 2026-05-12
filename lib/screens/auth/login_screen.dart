import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart'; 
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _estaCarregando = false;

  // Função para lidar com o Login do Google "Blindada" para Web
  void _fazerLoginGoogle() async {
    // 1. Inicia o estado de carregamento
    setState(() => _estaCarregando = true);

    try {
      // 2. Chama o serviço de autenticação
      bool sucesso = await _authService.entrarComGoogle();

      // 3. PAUSA ESTRATÉGICA (Crucial para Flutter Web)
      // Dá tempo para o popup do Google fechar e o Firebase estabilizar a sessão
      await Future.delayed(const Duration(milliseconds: 600));

      if (sucesso) {
        if (!mounted) return;

        // 4. Para o carregamento e limpa a pilha de telas indo para o Perfil
        setState(() => _estaCarregando = false);
        
        print("Navegando para a tela de Perfil...");
        Navigator.pushReplacementNamed(context, '/perfil');
      } else {
        // Se o login falhou ou foi cancelado pelo usuário
        if (!mounted) return;
        setState(() => _estaCarregando = false);
        
        _mostrarErro("O login foi cancelado ou falhou. Tente novamente!");
      }
    } catch (e) {
      // Captura erros inesperados e para o loading
      if (!mounted) return;
      setState(() => _estaCarregando = false);
      print("Erro capturado na LoginScreen: $e");
      _mostrarErro("Ocorreu um erro inesperado. Verifique o console.");
    }
  }

  // Função auxiliar para mostrar mensagens de erro
  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: AppColors.neonRosa,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundEscuro,
      body: Stack(
        children: [
          // FUNDO NEON
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
                  // MASCOTE CAL
                  Image.asset('assets/images/mascote_cal3.png', height: 180),
                  
                  const SizedBox(height: 20),
                  
                  const Text(
                    "MATEMÁTICA DIVERTIDA",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.neonCiano,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(color: AppColors.neonCiano, blurRadius: 15)
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  const Text(
                    "Sua aventura matemática começa aqui!",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  
                  const SizedBox(height: 50),

                  // ÁREA DO BOTÃO / CARREGAMENTO
                  _estaCarregando
                      ? const Column(
                          children: [
                            CircularProgressIndicator(color: AppColors.neonCiano),
                            SizedBox(height: 10),
                            Text("Autenticando...", 
                              style: TextStyle(color: AppColors.neonCiano))
                          ],
                        )
                      : SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: OutlinedButton.icon(
                            onPressed: _fazerLoginGoogle,
                            icon: const Icon(
                              Icons.account_circle,
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
                              side: const BorderSide(
                                  color: AppColors.neonCiano, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              backgroundColor:
                                  AppColors.backgroundCard.withOpacity(0.5),
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