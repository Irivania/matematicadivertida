// lib/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:matematicadivertida/l10n/app_localizations.dart'; // <- Importação necessária para as traduções

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
    // Escuta o GameState para garantir que a tela reaja imediatamente quando o idioma mudar
    context.watch<GameState>();
    
    final t = AppLocalizations.of(context)!; // Instância de tradução
    final larguraTela = MediaQuery.of(context).size.width;
    final bool eTelaLarga = larguraTela > 768;

    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: _animation,
        child: Stack(
          children: [
            // FUNDO DA TELA (Lousa Roxa)
            Positioned.fill(
              child: Image.asset(
                'assets/images/fundo_home.png', 
                fit: BoxFit.cover, 
                alignment: eTelaLarga ? Alignment.center : Alignment.topCenter,
              ),
            ),

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
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                            child: Container(
                              width: double.infinity,
                              constraints: BoxConstraints(
                                maxWidth: eTelaLarga ? 600 : 420,
                              ),
                              child: Column(
                                children: [
                                  // CABEÇALHO SUPERIOR (SAIR, IDIOMA E LOJA)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // GRUPO ESQUERDO: SAIR E IDIOMA
                                        Row(
                                          children: [
                                            _buildExitButton(context),
                                            const SizedBox(width: 8),
                                            _buildLanguageButton(context),
                                          ],
                                        ),
                                        
                                        // GRUPO DIREITO: LOJA
                                        GestureDetector(
                                          onTap: () => Navigator.push(
                                            context, 
                                            MaterialPageRoute(builder: (_) => const LojaScreen())
                                          ),
                                          child: AnimatedBuilder(
                                            animation: _glowController,
                                            builder: (context, child) => Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.12),
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(color: Colors.white70, width: 1.5),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.white.withOpacity(0.15 + (_glowController.value * 0.15)),
                                                    blurRadius: 8 + (_glowController.value * 6),
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                              child: child,
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.shopping_bag_rounded, color: Colors.white, size: 22),
                                                const SizedBox(width: 6),
                                                Text(
                                                  t.tituloLoja, // Texto traduzido dinamicamente
                                                  style: const TextStyle(
                                                    color: Colors.white, 
                                                    fontWeight: FontWeight.bold, 
                                                    fontSize: 14
                                                  )
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // LOGO PROFISSIONAL
                                  Transform.translate(
                                    offset: const Offset(0, -14),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: Image.asset(
                                        'assets/images/logo_matematica.png',
                                        height: eTelaLarga ? 270 : 230,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),

                                  // BLOCO INFERIOR
                                  Transform.translate(
                                    offset: const Offset(0, -22),
                                    child: Column(
                                      children: [
                                        // HEADER COM O NOME DO USUÁRIO
                                        const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 12),
                                          child: HomeHeader(), 
                                        ),

                                        const SizedBox(height: 10),

                                        // CONTEÚDO PRINCIPAL (MISSÃO E MODOS DE JOGO)
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            const MissionCard(),
                                            const SizedBox(height: 10),
                                            Text(
                                              t.modoTreino, // Substitua ou crie chaves arb equivalentes se necessário
                                              style: const TextStyle(
                                                color: Colors.white70, 
                                                fontSize: 11, 
                                                fontWeight: FontWeight.bold, 
                                                letterSpacing: 1.2
                                              )
                                            ),
                                            const SizedBox(height: 8),
                                            GameModeButton(
                                              titulo: t.modoTreino, 
                                              subtitulo: "Jogue sem pressão, sem perder vidas", 
                                              cor: AppColors.neonCiano, 
                                              onPressed: () => _navegarParaJogo(context, 'treino')
                                            ),
                                            const SizedBox(height: 8),
                                            GameModeButton(
                                              titulo: t.modoDisputa, 
                                              subtitulo: "Corra contra o tempo (2x XP)", 
                                              cor: Colors.amber, 
                                              onPressed: () => _navegarParaJogo(context, 'disputa')
                                            ),
                                            const SizedBox(height: 8),
                                            GameModeButton(
                                              titulo: t.rankingGlobal, 
                                              subtitulo: "Veja sua posição entre os melhores", 
                                              cor: const Color(0xFF7CFFB2), 
                                              onPressed: () => Navigator.push(
                                                context, 
                                                MaterialPageRoute(builder: (_) => const RankingScreen())
                                              ),
                                            ),
                                          ],
                                        ),
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

  // --- BOTÃO DE SELEÇÃO DE IDIOMA ---
  Widget _buildLanguageButton(BuildContext context) {
    return PopupMenuButton<Locale>(
      icon: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24),
        ),
        child: const Icon(Icons.language, color: Colors.white, size: 22),
      ),
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (Locale novoLocale) {
        // Altera o idioma e aciona o redesenho global da tela
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
              TextButton(
                onPressed: () => Navigator.pop(context), 
                child: const Text("OK")
              )
            ]
          )
        );
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5), 
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white24),
          ),
          child: const Icon(Icons.exit_to_app, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}