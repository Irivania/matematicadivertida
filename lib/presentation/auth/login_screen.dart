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

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _senhaController =
      TextEditingController();

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

            Navigator.pushReplacementNamed(
              context,
              AppRoutes.home,
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

            Navigator.pushReplacementNamed(
              context,
              AppRoutes.home,
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
    final alturaTela = MediaQuery.of(context).size.height;

    final bool eTelaLarga = larguraTela > 600;

    return Scaffold(
      backgroundColor: const Color(0xff1a103c),

      body: authController.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.neonCiano,
              ),
            )
          : Stack(
              children: [

                // =========================
                // IMAGEM DE FUNDO
                // =========================
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/imagem_login.png',
                    fit: BoxFit.cover,

                    // Ajuste fino da imagem
                    alignment: const Alignment(0, -0.15),
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
                          Colors.black.withOpacity(0.45),
                        ],
                      ),
                    ),
                  ),
                ),

                // =========================
                // CONTEÚDO
                // =========================
                Positioned.fill(
                  child: SafeArea(
                    child: Center(
                      child: SingleChildScrollView(
                        physics:
                            const BouncingScrollPhysics(),

                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 20,
                        ),

                        child: Container(
                          width: double.infinity,

                          constraints: BoxConstraints(
                            maxWidth:
                                eTelaLarga ? 420 : 380,
                          ),

                          child: Align(
                            // POSIÇÃO ENTRE PERSONAGENS
                            alignment:
                                const Alignment(0, 0.26),

                            child: Padding(
                              padding: EdgeInsets.only(
                                top: alturaTela * 0.22,
                              ),

                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(24),

                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 12,
                                    sigmaY: 12,
                                  ),

                                  child: Container(
                                    padding:
                                        const EdgeInsets.all(28),

                                    decoration: BoxDecoration(
                                      color:
                                          const Color(0xFF1A1A3A)
                                              .withOpacity(0.68),

                                      borderRadius:
                                          BorderRadius.circular(
                                              24),

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
                                          offset:
                                              const Offset(0, 8),
                                        ),
                                      ],
                                    ),

                                    child: Column(
                                      mainAxisSize:
                                          MainAxisSize.min,

                                      children: [

                                        // =========================
                                        // TÍTULO
                                        // =========================
                                        const Text(
                                          "ÁREA DE IDENTIFICAÇÃO",

                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight:
                                                FontWeight.bold,
                                            letterSpacing: 1.5,
                                          ),
                                        ),

                                        const SizedBox(
                                            height: 25),

                                        // =========================
                                        // E-MAIL
                                        // =========================
                                        TextField(
                                          controller:
                                              _emailController,

                                          style:
                                              const TextStyle(
                                            color: Colors.white,
                                          ),

                                          keyboardType:
                                              TextInputType
                                                  .emailAddress,

                                          decoration:
                                              InputDecoration(
                                            labelText:
                                                "E-mail",

                                            labelStyle:
                                                const TextStyle(
                                              color:
                                                  Colors.white70,
                                            ),

                                            prefixIcon:
                                                const Icon(
                                              Icons.email,
                                              color: AppColors
                                                  .neonCiano,
                                            ),

                                            filled: true,

                                            fillColor:
                                                Colors.black
                                                    .withOpacity(
                                                        0.30),

                                            enabledBorder:
                                                OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                          12),

                                              borderSide:
                                                  BorderSide(
                                                color: Colors
                                                    .white
                                                    .withOpacity(
                                                        0.10),
                                              ),
                                            ),

                                            focusedBorder:
                                                OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                          12),

                                              borderSide:
                                                  const BorderSide(
                                                color: AppColors
                                                    .neonCiano,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(
                                            height: 16),

                                        // =========================
                                        // SENHA
                                        // =========================
                                        TextField(
                                          controller:
                                              _senhaController,

                                          style:
                                              const TextStyle(
                                            color: Colors.white,
                                          ),

                                          obscureText:
                                              _ocultarSenha,

                                          decoration:
                                              InputDecoration(
                                            labelText:
                                                "Senha",

                                            labelStyle:
                                                const TextStyle(
                                              color:
                                                  Colors.white70,
                                            ),

                                            prefixIcon:
                                                const Icon(
                                              Icons.lock,
                                              color: AppColors
                                                  .neonCiano,
                                            ),

                                            filled: true,

                                            fillColor:
                                                Colors.black
                                                    .withOpacity(
                                                        0.30),

                                            suffixIcon:
                                                IconButton(
                                              icon: Icon(
                                                _ocultarSenha
                                                    ? Icons
                                                        .visibility_off
                                                    : Icons
                                                        .visibility,
                                                color: Colors
                                                    .white70,
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
                                                  BorderRadius
                                                      .circular(
                                                          12),

                                              borderSide:
                                                  BorderSide(
                                                color: Colors
                                                    .white
                                                    .withOpacity(
                                                        0.10),
                                              ),
                                            ),

                                            focusedBorder:
                                                OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                          12),

                                              borderSide:
                                                  const BorderSide(
                                                color: AppColors
                                                    .neonCiano,
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
                                              Alignment
                                                  .centerRight,

                                          child: TextButton(
                                            onPressed:
                                                _redefinirSenha,

                                            child: const Text(
                                              "Esqueci minha senha",

                                              style: TextStyle(
                                                color: AppColors
                                                    .neonCiano,
                                                fontSize: 13,
                                                fontWeight:
                                                    FontWeight
                                                        .w600,
                                              ),
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 8),

                                        // =========================
                                        // BOTÃO ENTRAR
                                        // =========================
                                        SizedBox(
                                          width:
                                              double.infinity,
                                          height: 48,

                                          child: ElevatedButton(
                                            style:
                                                ElevatedButton
                                                    .styleFrom(
                                              backgroundColor:
                                                  Colors.white
                                                      .withOpacity(
                                                          0.15),

                                              side: BorderSide(
                                                color: Colors
                                                    .white
                                                    .withOpacity(
                                                        0.30),
                                              ),

                                              shape:
                                                  RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                            12),
                                              ),
                                            ),

                                            onPressed:
                                                _fazerLoginEmail,

                                            child: const Text(
                                              "ENTRAR",

                                              style: TextStyle(
                                                color:
                                                    Colors.white,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                            ),
                                          ),
                                        ),

                                        // =========================
                                        // CADASTRO
                                        // =========================
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .center,

                                          children: [
                                            const Text(
                                              "Não tem uma conta?",

                                              style: TextStyle(
                                                color: Colors
                                                    .white70,
                                              ),
                                            ),

                                            TextButton(
                                              onPressed: () {
                                                Navigator.pushNamed(
                                                  context,
                                                  AppRoutes
                                                      .cadastro,
                                                );
                                              },

                                              child: const Text(
                                                "Cadastre-se",

                                                style:
                                                    TextStyle(
                                                  color: AppColors
                                                      .neonCiano,
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
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
                                              const EdgeInsets
                                                  .symmetric(
                                            vertical: 8,
                                          ),

                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Divider(
                                                  color: Colors
                                                      .white
                                                      .withOpacity(
                                                          0.20),
                                                ),
                                              ),

                                              const Padding(
                                                padding:
                                                    EdgeInsets
                                                        .symmetric(
                                                  horizontal: 10,
                                                ),

                                                child: Text(
                                                  "OU",

                                                  style:
                                                      TextStyle(
                                                    color: Colors
                                                        .white38,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),

                                              Expanded(
                                                child: Divider(
                                                  color: Colors
                                                      .white
                                                      .withOpacity(
                                                          0.20),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // =========================
                                        // GOOGLE
                                        // =========================
                                        SizedBox(
                                          width:
                                              double.infinity,
                                          height: 48,

                                          child:
                                              ElevatedButton.icon(
                                            icon: const Icon(
                                              Icons.login,
                                            ),

                                            label: const Text(
                                              "ENTRAR COM GOOGLE",

                                              style: TextStyle(
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                            ),

                                            style:
                                                ElevatedButton
                                                    .styleFrom(
                                              backgroundColor:
                                                  AppColors
                                                      .neonCiano,

                                              foregroundColor:
                                                  Colors.black,

                                              elevation: 2,

                                              shape:
                                                  RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                            12),
                                              ),
                                            ),

                                            onPressed:
                                                _fazerLoginGoogle,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}