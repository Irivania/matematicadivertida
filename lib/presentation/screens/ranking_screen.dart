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
    final larguraTela = MediaQuery.of(context).size.width;
    final bool eCelular = larguraTela < 768;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // IMAGEM DE FUNDO ORIGINAL RESTAURADA
            Positioned.fill(
              child: Image.asset(
                'assets/images/imagem_fundo_ranking.png',
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
            
            // Leve camada escura transparente para contraste
            Positioned.fill(child: Container(color: Colors.black.withOpacity(0.15))),

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
                          color: Colors.black, // TEXTO EM PRETO
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(color: Colors.white, blurRadius: 4),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.black, size: 22),
                        onPressed: _carregarDados,
                        tooltip: "Atualizar Estatísticas",
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // TÍTULO "MATEMÁTICA DIVERTIDA" NO TOPO
                  Text(
                    "Matemática Divertida",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: eCelular ? 24 : 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.1,
                      shadows: [
                        const Shadow(color: Colors.blueAccent, blurRadius: 6, offset: Offset(0, 2)),
                        const Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(2, 2)),
                      ],
                    ),
                  ),

                  // Espaçamento ajustado para respeitar a logo/espaço superior da imagem
                  const SizedBox(height: 140),

                  // ABAS (RANKING DISPUTA / MEU PROGRESSO) CENTRALIZADAS E COM LARGURA LIMITADA
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9), // Fundo sólido e limpo
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
                          tabs: const [
                            Tab(text: "🏆 RANKING DISPUTA"),
                            Tab(text: "🎖️ MEU PROGRESSO"),
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
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.black, width: 2)
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 12),
              SizedBox(width: 4),
              Text("SAIR", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12))
            ],
          ),
        ),
      );
}