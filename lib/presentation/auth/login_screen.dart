import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matematicadivertida/data/services/auth_service.dart';
import 'package:matematicadivertida/presentation/routes/app_routes.dart';
import 'package:matematicadivertida/core/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _estaCarregando = false;
  
  // Variável de controle para mostrar/ocultar a senha
  bool _ocultarSenha = true;

  // Controladores para capturar o e-mail e a senha digitados
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  /// Método para Login Tradicional com E-mail e Senha
  void _fazerLoginEmail() async {
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      _mostrarErro("Por favor, preencha todos os campos!");
      return;
    }

    setState(() => _estaCarregando = true);

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: senha,
      );
      
      if (credential.user != null) {
        if (!mounted) return;
        setState(() => _estaCarregando = false);
        Navigator.pushReplacementNamed(context, AppRoutes.perfil);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _estaCarregando = false);
      _mostrarErro("E-mail/Senha incorretos ou não cadastrados.");
    }
  }

  /// Método para Redefinição de Senha
  void _redefinirSenha() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _mostrarErro("Digite seu e-mail no campo acima para recuperar a senha!");
      return;
    }
    
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("E-mail de recuperação enviado com sucesso!"),
          backgroundColor: AppColors.neonVerde,
        ),
      );
    } catch (e) {
      _mostrarErro("Erro ao enviar e-mail de recuperação. Verifique o e-mail informado.");
    }
  }

  /// Método de login pelo Google
  void _fazerLoginGoogle() async {
    setState(() => _estaCarregando = true);

    try {
      final credential = await _authService.entrarComGoogle();
      final bool sucesso = credential != null;

      await Future.delayed(const Duration(milliseconds: 600));

      if (sucesso) {
        if (!mounted) return;
        setState(() => _estaCarregando = false);
        Navigator.pushReplacementNamed(context, AppRoutes.perfil);
      } else {
        if (!mounted) return;
        setState(() => _estaCarregando = false);
        _mostrarErro("O login foi cancelado ou falhou. Tente novamente!");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _estaCarregando = false);
      _mostrarErro("Erro ao autenticar com o Google.");
    }
  }

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
            : SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calculate, size: 80, color: AppColors.neonCiano),
                      const SizedBox(height: 10),
                      const Text(
                        "Matemática Divertida",
                        style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 40),

                      // --- CAMPO DE E-MAIL ---
                      TextField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: "E-mail",
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(Icons.email, color: AppColors.neonCiano),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.neonCiano),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // --- CAMPO DE SENHA (COM OPÇÃO DE VISUALIZAR) ---
                      TextField(
                        controller: _senhaController,
                        style: const TextStyle(color: Colors.white),
                        obscureText: _ocultarSenha, // Controla se mostra bolinhas ou texto
                        decoration: InputDecoration(
                          labelText: "Senha",
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(Icons.lock, color: AppColors.neonCiano),
                          
                          // Ícone do Olhinho no final do input
                          suffixIcon: IconButton(
                            icon: Icon(
                              _ocultarSenha ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              setState(() {
                                _ocultarSenha = !_ocultarSenha; // Inverte o estado do olho
                              });
                            },
                          ),
                          
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.neonCiano),
                          ),
                        ),
                      ),
                      
                      // --- LINK: ESQUECI MINHA SENHA ---
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _redefinirSenha,
                          child: const Text(
                            "Esqueci minha senha",
                            style: TextStyle(color: AppColors.neonCiano, fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // --- BOTÃO DE ENTRAR TRADICIONAL ---
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white10,
                            side: const BorderSide(color: Colors.white30),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _fazerLoginEmail,
                          child: const Text("ENTRAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      
                      // --- LINK: CADASTRAR NOVA CONTA (ROTA CONFIGURADA) ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Não tem uma conta?", style: TextStyle(color: Colors.white70)),
                          TextButton(
                            onPressed: () {
                              // ROTA DE CADASTRO DIRECIONADA:
                              // Se sua rota no AppRoutes se chamar 'cadastro' ou 'register', ajuste o nome abaixo:
                              Navigator.pushNamed(context, AppRoutes.cadastro);
                            },
                            child: const Text("Cadastre-se", style: TextStyle(color: AppColors.neonCiano, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Row(
                          children: [
                            Expanded(child: Divider(color: Colors.white24)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text("OU", style: TextStyle(color: Colors.white38, fontSize: 12)),
                            ),
                            Expanded(child: Divider(color: Colors.white24)),
                          ],
                        ),
                      ),

                      // --- BOTÃO DO GOOGLE ---
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.login),
                          label: const Text("ENTRAR COM GOOGLE", style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.neonCiano,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _fazerLoginGoogle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}