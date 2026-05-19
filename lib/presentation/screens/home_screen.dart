// lib/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../controllers/auth_controller.dart';
import 'ranking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _nomeController =
      TextEditingController();

  bool _isEditing = false;
  bool _inicializado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_inicializado) {
      final authController =
          Provider.of<AuthController>(
        context,
        listen: false,
      );

      String nomeSalvo = "";

      try {
        final dynamic usuario =
            authController.usuarioAtual;

        if (usuario != null) {
          nomeSalvo =
              usuario.nomeExibicao ??
              usuario.nome ??
              "";
        }
      } catch (_) {}

      if (nomeSalvo.trim().isEmpty) {
        nomeSalvo = authController.nomeJogador;
      }

      if (nomeSalvo.trim().isNotEmpty) {
        _nomeController.text = nomeSalvo;
      }

      _inicializado = true;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // =========================================
          // FUNDO NÍTIDO
          // =========================================
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/fundo_home.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  filterQuality: FilterQuality.high,
                ),

                // ESCURECIMENTO LEVE
                Container(
                  color: Colors.black.withOpacity(
                    0.12,
                  ),
                ),
              ],
            ),
          ),

          _buildBackgroundGlow(),

          // =========================================
          // CONTEÚDO
          // =========================================
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: ConstrainedBox(
                  constraints:
                      const BoxConstraints(
                    maxWidth: 700,
                  ),
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .center,
                    children: [
                      // BAIXA O CONTEÚDO
                      const SizedBox(
                        height: 170,
                      ),

                      _buildHeaderContext(
                        context,
                      ),

                      const SizedBox(
                        height: 26,
                      ),

                      const Text(
                        "ESCOLHA SEU MODO DE JOGO",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight:
                              FontWeight.bold,
                          letterSpacing:
                              1.2,
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      _buildGameModeButton(
                        context: context,
                        titulo:
                            "MODO TREINO",
                        subtitulo:
                            "Jogue sem pressão, sem perder vidas",
                        cor: AppColors
                            .neonCiano,
                        modo: "treino",
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      _buildGameModeButton(
                        context: context,
                        titulo:
                            "MODO DISPUTA 🏆",
                        subtitulo:
                            "Corra contra o tempo e pontue no Ranking",
                        cor: Colors.amber,
                        modo: "disputa",
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      _buildRankingButton(
                        context,
                      ),

                      const SizedBox(
                        height: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          _buildVersionFooter(),

          // =========================================
          // BOTÃO SAIR
          // =========================================
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black
                    .withOpacity(0.35),
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.exit_to_app,
                  color: Colors.white,
                  size: 30,
                ),
                tooltip: 'Sair do Jogo',
                onPressed: () async {
                  await Provider.of<
                      AuthController>(
                    context,
                    listen: false,
                  ).logout();

                  Future.delayed(
                    const Duration(
                      milliseconds: 200,
                    ),
                    () {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil(
                        '/',
                        (route) => false,
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================================
  // EFEITO DE LUZ
  // =========================================
  Widget _buildBackgroundGlow() {
    return Positioned(
      top: -120,
      right: -120,
      child: Container(
        width: 320,
        height: 320,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.neonCiano
              .withValues(alpha: 0.12),
        ),
      ),
    );
  }

  // =========================================
  // HEADER
  // =========================================
  Widget _buildHeaderContext(
    BuildContext context,
  ) {
    final authController =
        Provider.of<AuthController>(
      context,
    );

    String nomeSalvo = "";

    try {
      final dynamic usuario =
          authController.usuarioAtual;

      if (usuario != null) {
        nomeSalvo =
            usuario.nomeExibicao ??
            usuario.nome ??
            "";
      }
    } catch (_) {}

    if (nomeSalvo.trim().isEmpty) {
      nomeSalvo = authController.nomeJogador;
    }

    if (nomeSalvo.trim().isEmpty ||
        _isEditing) {
      return Column(
        children: [
          const Icon(
            Icons.account_circle,
            size: 44,
            color: AppColors.neonCiano,
          ),

          const SizedBox(height: 8),

          const Text(
            "BEM-VINDO(A)! 👋\nCOMO QUER SER CHAMADO(A)?",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller:
                      _nomeController,
                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                  decoration:
                      InputDecoration(
                    hintText:
                        "Digite seu apelido...",
                    hintStyle:
                        const TextStyle(
                      color:
                          Colors.white38,
                      fontSize: 12,
                    ),
                    filled: true,
                    fillColor:
                        Colors.black
                            .withOpacity(
                      0.25,
                    ),
                    border:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                      borderSide:
                          BorderSide.none,
                    ),
                    focusedBorder:
                        OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                      borderSide:
                          const BorderSide(
                        color: AppColors
                            .neonCiano,
                      ),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              IconButton.filled(
                style:
                    IconButton.styleFrom(
                  backgroundColor:
                      AppColors
                          .neonCiano,
                  foregroundColor:
                      AppColors
                          .backgroundEscuro,
                ),
                onPressed: () async {
                  final nomeDigitado =
                      _nomeController.text
                          .trim();

                  if (nomeDigitado
                      .isNotEmpty) {
                    try {
                      await authController
                          .escolherPerfilParaJogar(
                        nome:
                            nomeDigitado,
                        perfilEscolhido:
                            "crianca",
                      );
                    } catch (e) {
                      debugPrint(
                        "Erro ao salvar o nome: $e",
                      );
                    }

                    setState(
                      () =>
                          _isEditing =
                              false,
                    );
                  }
                },
                icon: const Icon(
                  Icons.check,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.only(
            top: 99,
          ),
          child: Text(
            "OLÁ, ${nomeSalvo.toUpperCase()}!",
            textAlign:
                TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight:
                  FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ),

        GestureDetector(
          onTap: () {
            _nomeController.text =
                nomeSalvo;

            setState(
              () => _isEditing =
                  true,
            );
          },
          child: const Padding(
            padding:
                EdgeInsets.only(
              top: 4,
            ),
            child: Text(
              "Editar apelido",
              style: TextStyle(
                color: AppColors
                    .neonCiano,
                fontSize: 11,
                decoration:
                    TextDecoration
                        .underline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================
  // BOTÕES DOS MODOS
  // =========================================
  Widget _buildGameModeButton({
    required BuildContext context,
    required String titulo,
    required String subtitulo,
    required Color cor,
    required String modo,
  }) {
    final authController =
        Provider.of<AuthController>(
      context,
      listen: false,
    );

    String nomeAtual =
        _nomeController.text.trim();

    if (nomeAtual.isEmpty) {
      try {
        final dynamic usuario =
            authController.usuarioAtual;

        if (usuario != null) {
          nomeAtual =
              usuario.nomeExibicao ??
              usuario.nome ??
              "";
        }
      } catch (_) {}
    }

    if (nomeAtual.isEmpty) {
      nomeAtual =
          authController.nomeJogador;
    }

    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: () {
          if (nomeAtual.trim().isEmpty ||
              _isEditing) {
            ScaffoldMessenger.of(
                    context)
                .showSnackBar(
              const SnackBar(
                content: Text(
                  "Digite e confirme seu apelido antes de continuar!",
                ),
                backgroundColor:
                    Colors.orange,
              ),
            );

            return;
          }

          Navigator.pushNamed(
            context,
            AppRoutes.perfil,
            arguments: {
              'nome': nomeAtual,
              'modo': modo,
            },
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: cor,
          foregroundColor:
              AppColors
                  .backgroundEscuro,
          elevation: 0,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              18,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 16,
                fontWeight:
                    FontWeight.bold,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              subtitulo,
              style: TextStyle(
                fontSize: 11,
                color: AppColors
                    .backgroundEscuro
                    .withOpacity(0.75),
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================
  // BOTÃO RANKING
  // =========================================
  Widget _buildRankingButton(
    BuildContext context,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const RankingScreen(),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              const Color(0xFF7CFFB2),
          foregroundColor:
              AppColors
                  .backgroundEscuro,
          elevation: 0,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              18,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Text(
              "RANKING GLOBAL",
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight:
                    FontWeight.bold,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              "Veja os melhores jogadores",
              style: TextStyle(
                fontSize: 11,
                color: AppColors
                    .backgroundEscuro
                    .withOpacity(0.75),
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================
  // VERSÃO
  // =========================================
  Widget _buildVersionFooter() {
    return const Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Text(
        "v1.0.0+1",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white38,
          fontSize: 12,
        ),
      ),
    );
  }
}