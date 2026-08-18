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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // FUNDO COM ALINHAMENTO CENTRALIZADO PARA ENQUADRAMENTO PERFEITO NO CELULAR
            Positioned.fill(
              child: Image.asset(
                'assets/images/imagem_fundo_ranking.png', 
                fit: BoxFit.cover, 
                alignment: Alignment.center,
              ),
            ),
            // Fundo mais claro (opacidade 0.35)
            Positioned.fill(child: Container(color: Colors.black.withOpacity(0.35))),
            
            Padding(
              padding: const EdgeInsets.only(top: 30, left: 16, right: 16, bottom: 16),
              child: Column(
                children: [
                  // Cabeçalho: Botão Sair na esquerda e Estatísticas na DIREITA
                  Row(
                    children: [
                      _buildBotaoSair(context),
                      const Spacer(), 
                      const Text(
                        "ESTATÍSTICAS",
                        style: TextStyle(
                          color: Colors.white, 
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: AppColors.neonCiano, size: 20),
                        onPressed: _carregarDados,
                        tooltip: "Atualizar Estatísticas",
                      ),
                    ],
                  ),

                  // Espaço para afastar da logo da imagem de fundo
                  const SizedBox(height: 250),

                  // Abas (Ranking Disputa / Meu Progresso)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: TabBar(
                      indicator: BoxDecoration(
                        color: AppColors.neonCiano,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.white,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      tabs: const [
                        Tab(text: "🏆 RANKING DISPUTA"),
                        Tab(text: "🎖️ MEU PROGRESSO"),
                      ],
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
          ],
        ),
      ),
    );
  }

  Widget _buildBotaoSair(BuildContext context) => InkWell(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7), 
            borderRadius: BorderRadius.circular(30), 
            border: Border.all(color: AppColors.neonCiano, width: 2)
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 12), 
              SizedBox(width: 4), 
              Text("SAIR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))
            ],
          ),
        ),
      );
}