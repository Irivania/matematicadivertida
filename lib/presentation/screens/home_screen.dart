// lib/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:matematicadivertida/l10n/app_localizations.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<GameState>();
    final t = AppLocalizations.of(context)!;
    final larguraTela = MediaQuery.of(context).size.width;
    final bool eTelaLarga = larguraTela > 768;

    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _animation,
        child: Stack(
          children: [
            // Fundo Gradiente com Tons Mais Claros e Iluminados
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF5A2A82), // Roxo mais claro e vibrante no topo
                      Color(0xFF3B1D59), // Roxo intermediário suave
                      Color(0xFF221133), // Tom de transição mais claro na base
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: eTelaLarga ? 600 : 420,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        // 1. CABEÇALHO SUPERIOR COMPACTO
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                _buildExitButton(context),
                                const SizedBox(width: 8),
                                _buildLanguageButton(context),
                              ],
                            ),
                            _buildShopButton(context, t),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // 2. LOGO
                        Image.asset(
                          'assets/images/logo_matematica.png',
                          height: eTelaLarga ? 200 : 160,
                          fit: BoxFit.contain,
                        ),

                        const SizedBox(height: 4),

                        // 3. HEADER COM O NOME DO USUÁRIO
                        const HomeHeader(),

                        const SizedBox(height: 8),

                        // 4. CONTEÚDO PRINCIPAL
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const MissionCard(),
                                const SizedBox(height: 12),
                                Text(
                                  t.modoTreino,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                GameModeButton(
                                  titulo: t.modoTreino,
                                  subtitulo: "Jogue sem pressão, sem perder vidas",
                                  cor: AppColors.neonCiano,
                                  onPressed: () => _navegarParaJogo(context, 'treino'),
                                ),
                                const SizedBox(height: 8),
                                GameModeButton(
                                  titulo: t.modoDisputa,
                                  subtitulo: "Corra contra o tempo (2x XP)",
                                  cor: Colors.amber,
                                  onPressed: () => _navegarParaJogo(context, 'disputa'),
                                ),
                                const SizedBox(height: 8),
                                GameModeButton(
                                  titulo: t.rankingGlobal,
                                  subtitulo: "Veja sua posição entre os melhores",
                                  cor: const Color(0xFF7CFFB2),
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const RankingScreen()),
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                            ),
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
    );
  }

  // --- BOTÕES AUXILIARES COMPACTOS ---
  Widget _buildLanguageButton(BuildContext context) {
    return PopupMenuButton<Locale>(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white30),
        ),
        child: const Icon(Icons.language, color: Colors.white, size: 20),
      ),
      color: const Color(0xFF2E1A47),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (Locale novoLocale) {
        context.read<GameState>().mudarIdioma(novoLocale);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
        const PopupMenuItem<Locale>(
          value: Locale('pt', 'BR'),
          child: Text('🇧🇷 Português', style: TextStyle(color: Colors.white)),
        ),
        const PopupMenuItem<Locale>(
          value: Locale('en', 'US'),
          child: Text('🇺🇸 English', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildShopButton(BuildContext context, AppLocalizations t) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LojaScreen())),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white70, width: 1.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 6),
            Text(
              t.tituloLoja,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExitButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
          Future.microtask(() async {
            try {
              await Provider.of<AuthController>(context, listen: false).logout();
            } catch (e) {
              debugPrint("Erro ao deslogar: $e");
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white30),
          ),
          child: const Icon(Icons.exit_to_app, color: Colors.white, size: 20),
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
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Ops! Sem vidas 💔"),
            content: const Text("Visite a Loja!"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))
            ],
          ),
        );
      }
    } else {
      Navigator.pushNamed(context, AppRoutes.perfil, arguments: {'modo': modo, 'isModoDisputa': false});
    }
  }
}