import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:matematicadivertida/presentation/controllers/auth_controller.dart'; 
import 'package:matematicadivertida/domain/repositories/i_auth_repository.dart';
import 'package:matematicadivertida/presentation/routes/app_routes.dart';
import 'package:matematicadivertida/core/theme/app_colors.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
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

  /// Método principal conectado à arquitetura do app (AuthController)
  void _cadastrarUsuario() async {
    // PRINT DE DIAGNÓSTICO: Veja se esta linha aparece no terminal ao clicar!
    print("⚡ CLIQUE DETECTADO: A função _cadastrarUsuario foi acionada!");

    final authController = context.read<AuthController>();

    // Proteção manual contra cliques duplos sem desativar o botão nativamente
    if (authController.isLoading) {
      print("⚠️ CLIQUE IGNORADO: O AuthController já está processando uma requisição.");
      return;
    }

    final nome = _nomeController.text.trim();
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();
    final confirmarSenha = _confirmarSenhaController.text.trim();

    // 1. Validação de campos vazios locais
    if (nome.isEmpty || email.isEmpty || senha.isEmpty || confirmarSenha.isEmpty) {
      _mostrarMensagem("Por favor, preencha todos os campos!", Colors.redAccent);
      return;
    }

    // 2. Validação de igualdade de senhas
    if (senha != confirmarSenha) {
      _mostrarMensagem("As senhas não coincidem!", Colors.redAccent);
      return;
    }

    // 3. Validação de tamanho mínimo da senha
    if (senha.length < 6) {
      _mostrarMensagem("A senha deve conter pelo menos 6 caracteres!", Colors.redAccent);
      return;
    }

    try {
      print("🚀 ENVIANDO DADOS: Chamando authController.cadastrarComEmail...");
      authController.cadastrarComEmail(
        email: email,
        senha: senha,
        nome: nome,
        onSuccess: () async {
          print("✅ SUCESSO: Usuário cadastrado no Firebase!");
          if (!mounted) return;
          _mostrarMensagem("Conta criada com sucesso!", AppColors.neonVerde);
          
          await Future.delayed(const Duration(milliseconds: 600));
          if (!mounted) return;

          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.perfil, (route) => false);
        },
        onError: (mensagemErro) {
          print("❌ ERRO DO FIREBASE: $mensagemErro");
          if (!mounted) return;
          _mostrarMensagem(mensagemErro, Colors.redAccent);
        },
      );
    } catch (e) {
      print("💥 EXCEÇÃO CAPTURADA: Erro crítico ao tentar chamar o controller: $e");
      _mostrarMensagem("Erro ao processar o cadastro: $e", Colors.redAccent);
    }
  }

  void _mostrarMensagem(String message, Color corSucessoOuErro) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar(); 
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: corSucessoOuErro,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    // PRINT DE ESTADO: Monitora o estado reativo do controller toda vez que a tela redesenha
    print("📺 RENDERIZANDO TELA: authController.isLoading atual é = ${authController.isLoading}");

    return Scaffold(
      backgroundColor: AppColors.backgroundEscuro,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white, 
      ),
      body: Center(
        child: SingleChildScrollView(
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
                    // Forçamos o botão a ficar sempre ativo para o clique passar de qualquer forma!
                    onPressed: _cadastrarUsuario, 
                    child: authController.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text("CRIAR CONTA"),
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