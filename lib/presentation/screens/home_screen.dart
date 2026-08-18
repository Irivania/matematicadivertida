// lib/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../routes/app_routes.dart';
import '../auth/login_screen.dart';
import '../../core/theme/app_colors.dart';
import '../controllers/auth_controller.dart';
import '../../data/models/game_state.dart';
import '../widgets/home/home_header.dart';
import '../widgets/home/game_mode_button.dart';
import '../widgets/home/mission_card.dart';
import 'ranking_screen.dart';
import 'loja_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final larguraTela = MediaQuery.of(context).size.width;
    final bool eTelaLarga = larguraTela > 600;

    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _animation,
        child: Stack(
          children: [
            // FUNDO COM ALINHAMENTO SUPERIOR PARA NÃO CORTAR O LOGO
            Positioned.fill(
              child: Image.asset(
                'assets/images/fundo_home.png', 
                fit: BoxFit.cover, 
                alignment: Alignment.topCenter,
              ),
            ),
            Container(color: Colors.black.withOpacity(0.12)),
            _buildBackgroundGlow(),

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
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: Container(
                              width: double.infinity,
                              constraints: BoxConstraints(
                                maxWidth: eTelaLarga ? 500 : 420,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      // BOTÃO SAIR BEM NA ESQUERDA
                                      _buildExitButton(context),

                                      // LOJA DO CAL COM BORDA AZUL CLARO (NEON CIANO), TEXTO EM PRETO E ÍCONE EM BRANCO
                                      GestureDetector(
                                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LojaScreen())),
                                        child: AnimatedBuilder(
                                          animation: _glowController,
                                          builder: (context, child) => Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(15),
                                              border: Border.all(color: AppColors.neonCiano, width: 1.5),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors.neonCiano.withOpacity(0.3 + (_glowController.value * 0.3)),
                                                  blurRadius: 10 + (_glowController.value * 10),
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                            child: child,
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(Icons.shopping_bag, color: Colors.white, size: 36),
                                              SizedBox(width: 8),
                                              Text("Loja do Cal", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16, shadows: [Shadow(color: Colors.white, blurRadius: 4)])),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  // AUMENTADO PARA 200 PARA DESCER MAIS O TEXTO "OLÁ FRANCISCO"
                                  const SizedBox(height: 200), 
                                  
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16),
                                    child: HomeHeader(),
                                  ),

                                  const SizedBox(height: 20),

                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const MissionCard(),
                                        const SizedBox(height: 20),
                                        const Text("ESCOLHA SEU MODO DE JOGO", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                                        const SizedBox(height: 12),
                                        GameModeButton(titulo: "MODO TREINO", subtitulo: "Jogue sem pressão, sem perder vidas", cor: AppColors.neonCiano, onPressed: () => _navegarParaJogo(context, 'treino')),
                                        const SizedBox(height: 10),
                                        GameModeButton(titulo: "MODO DISPUTA 🏆", subtitulo: "Corra contra o tempo (2x XP)", cor: Colors.amber, onPressed: () => _navegarParaJogo(context, 'disputa')),
                                        const SizedBox(height: 10),
                                        _buildRankingButton(context),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
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
      ),
    );
  }

  void _navegarParaJogo(BuildContext context, String modo) {
    final gs = context.read<GameState>();
    if (modo == 'disputa') {
      if (gs.vidas > 0) {
        gs.vidas--; 
        gs.notifyListeners();
        Navigator.pushNamed(context, AppRoutes.perfil, arguments: {'modo': modo, 'isModoDisputa': true});
      } else {
        showDialog(context: context, builder: (_) => AlertDialog(title: const Text("Ops! Sem vidas 💔"), content: const Text("Visite a Loja!"), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))]));
      }
    } else {
      Navigator.pushNamed(context, AppRoutes.perfil, arguments: {'modo': modo, 'isModoDisputa': false});
    }
  }

  Widget _buildExitButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          debugPrint("DEBUG: Botão de saída clicado na HomeScreen!");
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
          Future.microtask(() async {
            try {
              await Provider.of<AuthController>(context, listen: false).logout();
            } catch (e) {
              debugPrint("Erro ao deslogar em segundo plano: $e");
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5), 
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white24),
          ),
          child: const Icon(Icons.exit_to_app, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  Widget _buildRankingButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7CFFB2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RankingScreen())),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("RANKING GLOBAL", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundGlow() {
    return Positioned(
      top: -120, right: -120,
      child: Container(width: 320, height: 320, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.neonCiano.withValues(alpha: 0.12))),
    );
  }
}