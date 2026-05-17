import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matematicadivertida/presentation/routes/app_routes.dart';
import 'package:matematicadivertida/core/theme/app_colors.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  bool _estaCarregando = false;
  
  // Variáveis para controlar a visibilidade das senhas
  bool _ocultarSenha = true;
  bool _ocultarConfirmarSenha = true;

  // Controladores para capturar os dados digitados
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();
  final TextEditingController _confirmarSenhaController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  /// Método principal para registrar o usuário no Firebase
  void _cadastrarUsuario() async {
    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();
    final confirmarSenha = _confirmarSenhaController.text.trim();

    // 1. Validação de campos vazios
    if (nome.isEmpty || email.isEmpty || senha.isEmpty || confirmarSenha.isEmpty) {
      _mostrarMensagem("Por favor, preencha todos os campos!", Colors.redAccent);
      return;
    }

    // 2. Validação de igualdade de senhas
    if (senha != confirmarSenha) {
      _mostrarMensagem("As senhas não coincidem!", Colors.redAccent);
      return;
    }

    // 3. Validação de tamanho da senha (exigência do Firebase)
    if (senha.length < 6) {
      _mostrarMensagem("A senha deve conter pelo menos 6 caracteres!", Colors.redAccent);
      return;
    }

    setState(() => _estaCarregando = true);

    try {
      // Cria o usuário no Firebase Authentication
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: senha,
      );

      // Atualiza o perfil do usuário no Firebase com o Nome digitado
      if (userCredential.user != null) {
        await userCredential.user!.updateDisplayName(nome);
        
        if (!mounted) return;
        setState(() => _estaCarregando = false);
        
        _mostrarMensagem("Conta criada com sucesso!", AppColors.neonVerde);
        
        // Pausa estratégica e navega direto para a tela de seleção de perfis
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.perfil, (route) => false);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _estaCarregando = false);
      
      // Tratamento de erros comuns do Firebase
      if (e.code == 'email-already-in-use') {
        _mostrarMensagem("Este e-mail já está cadastrado!", Colors.redAccent);
      } else if (e.code == 'invalid-email') {
        _mostrarMensagem("O e-mail digitado é inválido.", Colors.redAccent);
      } else {
        _mostrarMensagem("Erro ao cadastrar: ${e.message}", Colors.redAccent);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _estaCarregando = false);
      _mostrarMensagem("Ocorreu um erro inesperado. Tente novamente.", Colors.redAccent);
    }
  }

  void _mostrarMensagem(String mensagem, Color corSucessoOuErro) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: corSucessoOuErro,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundEscuro,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white, // Seta de voltar branca
      ),
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
                      const Icon(Icons.app_registration, size: 70, color: AppColors.neonCiano),
                      const SizedBox(height: 10),
                      const Text(
                        "Criar Nova Conta",
                        style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 30),

                      // --- CAMPO DE NOME ---
                      TextField(
                        controller: _nomeController,
                        style: const TextStyle(color: Colors.white),
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: "Nome Completo",
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(Icons.person, color: AppColors.neonCiano),
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

                      // --- CAMPO DE SENHA ---
                      TextField(
                        controller: _senhaController,
                        style: const TextStyle(color: Colors.white),
                        obscureText: _ocultarSenha,
                        decoration: InputDecoration(
                          labelText: "Senha (mínimo 6 caracteres)",
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(Icons.lock, color: AppColors.neonCiano),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _ocultarSenha ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white70,
                            ),
                            onPressed: () => setState(() => _ocultarSenha = !_ocultarSenha),
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
                      const SizedBox(height: 20),

                      // --- CAMPO DE CONFIRMAR SENHA ---
                      TextField(
                        controller: _confirmarSenhaController,
                        style: const TextStyle(color: Colors.white),
                        obscureText: _ocultarConfirmarSenha,
                        decoration: InputDecoration(
                          labelText: "Confirmar Senha",
                          labelStyle: const TextStyle(color: Colors.white70),
                          prefixIcon: const Icon(Icons.lock_clock, color: AppColors.neonCiano),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _ocultarConfirmarSenha ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white70,
                            ),
                            onPressed: () => setState(() => _ocultarConfirmarSenha = !_ocultarConfirmarSenha),
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
                      const SizedBox(height: 35),

                      // --- BOTÃO CONFIRMAR CADASTRO ---
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.neonCiano,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          onPressed: _cadastrarUsuario,
                          child: const Text("CRIAR CONTA"),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}