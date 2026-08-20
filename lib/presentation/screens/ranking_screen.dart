// lib/presentation/screens/ranking_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/game_state.dart';
import '../../data/services/ranking_service.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/ranking_global_tab.dart';
import '../widgets/meu_progresso_tab.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final RankingService _rankingService = RankingService();
  late Future<List<Map<String, dynamic>>> _futureRankingGlobal;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameState>().carregarRecordesLocais();
    });
    setState(() {
      _futureRankingGlobal = _rankingService.buscarRankingGlobal();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final bool eIngles = gameState.currentLocale.languageCode == 'en';
    final larguraTela = MediaQuery.of(context).size.width;
    final bool eCelular = larguraTela < 768;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFF532287),
        body: Stack(
          children: [
            // 1. FUNDO ROXO MÁGICO UNIFICADO (Idêntico ao da Home/Jogo)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF8A49C9), Color(0xFF532287), Color(0xFF221133)],
                  ),
                ),
                child: Stack(
                  children: List.generate(8, (i) => Positioned(
                    left: (i * 50.0) % 300, 
                    top: (i * 80.0) % 600,
                    child: Icon(Icons.calculate_outlined, color: Colors.white.withOpacity(0.06), size: 60),
                  )),
                ),
              ),
            ),
            
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    // Cabeçalho: Botão Sair na esquerda e Botão Atualizar na direita
                    Row(
                      children: [
                        _buildBotaoSair(context, eIngles),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.white, size: 24),
                          onPressed: _carregarDados,
                          tooltip: eIngles ? "Refresh Statistics" : "Atualizar Estatísticas",
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // LOGO OFICIAL NO TOPO (Padrão Home)
                    Image.asset(
                      'assets/images/logo_matematica.png', 
                      height: eCelular ? 130 : 170, 
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 10),

                    // ABAS (RANKING DISPUTA / MEU PROGRESSO) TRADUZIDAS E COM LARGURA LIMITADA
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9), 
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                            border: Border.all(color: Colors.black26),
                          ),
                          child: TabBar(
                            indicator: BoxDecoration(
                              color: AppColors.neonCiano,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            labelColor: Colors.black,
                            unselectedLabelColor: Colors.black54,
                            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            tabs: [
                              Tab(text: eIngles ? "🏆 CHALLENGE" : "🏆 RANKING"),
                              Tab(text: eIngles ? "🎖️ PROGRESS" : "🎖️ PROGRESSO"),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Conteúdo das Abas
                    Expanded(
                      child: TabBarView(
                        children: [
                          RankingGlobalTab(
                            futureRanking: _futureRankingGlobal,
                            onRefresh: _carregarDados,
                          ),
                          MeuProgressoTab(gameState: gameState),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotaoSair(BuildContext context, bool eIngles) => InkWell(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_back, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                eIngles ? "EXIT" : "SAIR", 
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              )
            ],
          ),
        ),
      );
}