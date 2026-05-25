// lib/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../routes/app_routes.dart';
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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin { // Mudado para TickerProvider
  late AnimationController _controller;
  late Animation<double> _animation;
  late AnimationController _glowController; // Novo controlador para o pulso

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // Controlador para o efeito de pulso
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
    return Scaffold(
      body: FadeTransition(
        opacity: _animation,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset('assets/images/fundo_home.png', fit: BoxFit.cover, alignment: Alignment.topCenter),
            ),
            Container(color: Colors.black.withOpacity(0.12)),
            _buildBackgroundGlow(),

            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Loja do Cal com Efeito Pulsante
                        GestureDetector(
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LojaScreen())),
                          child: AnimatedBuilder(
                            animation: _glowController,
                            builder: (context, child) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: Colors.red.withOpacity(0.5), width: 1),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.3 + (_glowController.value * 0.3)), // Brilho oscilante
                                    blurRadius: 10 + (_glowController.value * 10),
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: child,
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.shopping_bag, color: Colors.amber, size: 50),
                                SizedBox(width: 8),
                                Text("Loja do Cal", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18, shadows: [Shadow(color: Colors.black, blurRadius: 4)])),
                              ],
                            ),
                          ),
                        ),
                        _buildExitButton(context),
                      ],
                    ),
                  ),

                  const SizedBox(height: 175), 
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: HomeHeader(),
                  ),

                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 700),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const MissionCard(),
                              const SizedBox(height: 25),
                              const Text("ESCOLHA SEU MODO DE JOGO", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                              const SizedBox(height: 15),
                              GameModeButton(titulo: "MODO TREINO", subtitulo: "Jogue sem pressão, sem perder vidas", cor: AppColors.neonCiano, onPressed: () => _navegarParaJogo(context, 'treino')),
                              const SizedBox(height: 10),
                              GameModeButton(titulo: "MODO DISPUTA 🏆", subtitulo: "Corra contra o tempo (2x XP)", cor: Colors.amber, onPressed: () => _navegarParaJogo(context, 'disputa')),
                              const SizedBox(height: 10),
                              _buildRankingButton(context),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... (Restante dos métodos permanecem iguais)
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
    return Container(
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.35), borderRadius: BorderRadius.circular(14)),
      child: IconButton(
        icon: const Icon(Icons.exit_to_app, color: Colors.white, size: 30),
        onPressed: () async {
          await Provider.of<AuthController>(context, listen: false).logout();
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        },
      ),
    );
  }

  Widget _buildRankingButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
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