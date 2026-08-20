// lib/presentation/auth/login_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';
import '../../presentation/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _ocultarSenha = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  void _fazerLoginEmail() {
    final email = _emailController.text.trim();
    final senha = _senhaController.text.trim();

    if (email.isEmpty || senha.isEmpty) {
      _mostrarErro("Por favor, preencha todos os campos!");
      return;
    }

    context.read<AuthController>().loginComEmail(
          email: email,
          senha: senha,
          onSuccess: () {
            if (!mounted) return;

            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
              (route) => false,
            );
          },
          onError: (mensagemErro) {
            if (!mounted) return;

            _mostrarErro(mensagemErro);
          },
        );
  }

  void _redefinirSenha() {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _mostrarErro(
        "Digite seu e-mail no campo acima para recuperar a senha!",
      );
      return;
    }

    context.read<AuthController>().recuperarSenha(
          email: email,
          onSuccess: () {
            if (!mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "E-mail de recuperação enviado com sucesso!",
                ),
                backgroundColor: AppColors.neonVerde,
              ),
            );
          },
          onError: (mensagemErro) {
            if (!mounted) return;

            _mostrarErro(mensagemErro);
          },
        );
  }

  void _fazerLoginGoogle() {
    context.read<AuthController>().loginComGoogle(
          onSuccess: () {
            if (!mounted) return;

            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
              (route) => false,
            );
          },
          onError: (mensagemErro) {
            if (!mounted) return;

            _mostrarErro(mensagemErro);
          },
        );
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
    final authController = context.watch<AuthController>();
    final larguraTela = MediaQuery.of(context).size.width;
    final bool eTelaLarga = larguraTela > 600;

    return Scaffold(
      backgroundColor: const Color(0xff1a103c),
      resizeToAvoidBottomInset: true,
      body: authController.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.neonCiano,
              ),
            )
          : Stack(
              children: [
                // =========================
                // IMAGEM DE FUNDO COM ENQUADRAMENTO CENTRALIZADO
                // =========================
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/imagem_login.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),

                // =========================
                // OVERLAY ESCURO
                // =========================
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.15),
                        ],
                      ),
                    ),
                  ),
                ),

                // =========================
                // CONTEÚDO RESPONSIVO SEGURO
                // =========================
                SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // ESPAÇAMENTO SUPERIOR MAIOR PARA DESCER BEM O CARD
                                    const SizedBox(height: 120),

                                    Container(
                                      width: double.infinity,
                                      constraints: BoxConstraints(
                                        maxWidth: eTelaLarga ? 420 : 380,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                            sigmaX: 12,
                                            sigmaY: 12,
                                          ),
                                          child: Container(
                                            // PADDING INTERNO REDUZIDO PARA ENCOLHER O CARD
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20, 
                                              vertical: 18,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF1A1A3A)
                                                  .withOpacity(0.72),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Colors.white
                                                    .withOpacity(0.20),
                                                width: 1.5,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.35),
                                                  blurRadius: 20,
                                                  offset: const Offset(0, 8),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // =========================
                                                // TÍTULO
                                                // =========================
                                                const Text(
                                                  "ÁREA DE IDENTIFICAÇÃO",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 1.2,
                                                  ),
                                                ),

                                                const SizedBox(height: 14),

                                                // =========================
                                                // E-MAIL
                                                // =========================
                                                TextField(
                                                  controller: _emailController,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                  ),
                                                  keyboardType:
                                                      TextInputType.emailAddress,
                                                  decoration: InputDecoration(
                                                    labelText: "E-mail",
                                                    labelStyle: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 12,
                                                    ),
                                                    isDense: true,
                                                    prefixIcon: const Icon(
                                                      Icons.email,
                                                      color: AppColors.neonCiano,
                                                      size: 20,
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.black
                                                        .withOpacity(0.30),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      borderSide: BorderSide(
                                                        color: Colors.white
                                                            .withOpacity(0.10),
                                                      ),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      borderSide:
                                                          const BorderSide(
                                                        color: AppColors.neonCiano,
                                                        width: 2,
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                const SizedBox(height: 10),

                                                // =========================
                                                // SENHA
                                                // =========================
                                                TextField(
                                                  controller: _senhaController,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 13,
                                                  ),
                                                  obscureText: _ocultarSenha,
                                                  decoration: InputDecoration(
                                                    labelText: "Senha",
                                                    labelStyle: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 12,
                                                    ),
                                                    isDense: true,
                                                    prefixIcon: const Icon(
                                                      Icons.lock,
                                                      color: AppColors.neonCiano,
                                                      size: 20,
                                                    ),
                                                    filled: true,
                                                    fillColor: Colors.black
                                                        .withOpacity(0.30),
                                                    suffixIcon: IconButton(
                                                      icon: Icon(
                                                        _ocultarSenha
                                                            ? Icons
                                                                .visibility_off
                                                            : Icons.visibility,
                                                        color: Colors.white70,
                                                        size: 18,
                                                      ),
                                                      onPressed: () {
                                                        setState(() {
                                                          _ocultarSenha =
                                                              !_ocultarSenha;
                                                        });
                                                      },
                                                    ),
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      borderSide: BorderSide(
                                                        color: Colors.white
                                                            .withOpacity(0.10),
                                                      ),
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      borderSide:
                                                          const BorderSide(
                                                        color: AppColors.neonCiano,
                                                        width: 2,
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                // =========================
                                                // RECUPERAR SENHA
                                                // =========================
                                                Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: TextButton(
                                                    style: TextButton.styleFrom(
                                                      padding: EdgeInsets.zero,
                                                      minimumSize: const Size(0, 24),
                                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    ),
                                                    onPressed: _redefinirSenha,
                                                    child: const Text(
                                                      "Esqueci minha senha",
                                                      style: TextStyle(
                                                        color: AppColors.neonCiano,
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                const SizedBox(height: 6),

                                                // =========================
                                                // BOTÃO ENTRAR
                                                // =========================
                                                SizedBox(
                                                  width: double.infinity,
                                                  height: 42,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor: Colors.white
                                                          .withOpacity(0.15),
                                                      side: BorderSide(
                                                        color: Colors.white
                                                            .withOpacity(0.30),
                                                      ),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                10),
                                                      ),
                                                    ),
                                                    onPressed: _fazerLoginEmail,
                                                    child: const Text(
                                                      "ENTRAR",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                const SizedBox(height: 6),

                                                // =========================
                                                // CADASTRO
                                                // =========================
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Text(
                                                      "Não tem uma conta?",
                                                      style: TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    TextButton(
                                                      style: TextButton.styleFrom(
                                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                                        minimumSize: const Size(0, 24),
                                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                      ),
                                                      onPressed: () {
                                                        Navigator.pushNamed(
                                                          context,
                                                          AppRoutes.cadastro,
                                                        );
                                                      },
                                                      child: const Text(
                                                        "Cadastre-se",
                                                        style: TextStyle(
                                                          color: AppColors
                                                              .neonCiano,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                // =========================
                                                // DIVISOR
                                                // =========================
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    vertical: 6,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Divider(
                                                          color: Colors.white
                                                              .withOpacity(0.20),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 8,
                                                        ),
                                                        child: Text(
                                                          "OU",
                                                          style: TextStyle(
                                                            color: Colors.white38,
                                                            fontSize: 11,
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Divider(
                                                          color: Colors.white
                                                              .withOpacity(0.20),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                // =========================
                                                // GOOGLE
                                                // =========================
                                                SizedBox(
                                                  width: double.infinity,
                                                  height: 42,
                                                  child: ElevatedButton.icon(
                                                    icon: const Icon(
                                                      Icons.login,
                                                      size: 18,
                                                    ),
                                                    label: const Text(
                                                      "ENTRAR COM GOOGLE",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          AppColors.neonCiano,
                                                      foregroundColor:
                                                          Colors.black,
                                                      elevation: 2,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                10),
                                                      ),
                                                    ),
                                                    onPressed: _fazerLoginGoogle,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}