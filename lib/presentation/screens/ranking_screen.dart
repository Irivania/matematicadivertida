// lib/presentation/screens/ranking_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/game_state.dart';
import '../../../data/services/ranking_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/enums/nivel_enum.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameState>().carregarRecordesLocais();
    });
    _futureRankingGlobal = _rankingService.buscarRankingGlobal();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();

    return DefaultTabController(
      length: 2, // Duas abas: Ranking Global e Meu Progresso
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Imagem de Fundo
            Positioned.fill(
              child: Image.asset(
                'assets/images/imagem_fundo_ranking.png', 
                fit: BoxFit.cover, 
                alignment: Alignment.topCenter
              ),
            ),
            // Overlay escuro para legibilidade
            Positioned.fill(child: Container(color: Colors.black.withOpacity(0.65))),
            
            SafeArea(
              child: Column(
                children: [
                  // --- CABEÇALHO COM BOTÃO SAIR E TÍTULO ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildBotaoSair(context),
                        const Text(
                          "ESTATÍSTICAS",
                          style: TextStyle(
                            color: Colors.white, 
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2
                          ),
                        ),
                        const SizedBox(width: 80),
                      ],
                    ),
                  ),

                  // --- ABAS DE NAVEGAÇÃO (TAB BAR) ---
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

                  // --- CONTEÚDO DAS ABAS ---
                  Expanded(
                    child: TabBarView(
                      children: [
                        // ABA 1: RANKING GLOBAL (Modo Disputa)
                        _buildAbaRankingGlobal(),

                        // ABA 2: MEU PROGRESSO (Separado por Perfil)
                        _buildAbaMeuProgresso(gameState),
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

  // --- ABA 1: LISTA DO RANKING GLOBAL ---
  Widget _buildAbaRankingGlobal() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _futureRankingGlobal,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.neonCiano),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: _buildNenhumDado("Nenhum recorde no Modo Disputa ainda!"));
        }
        
        final rankingGlobal = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: rankingGlobal.length,
          itemBuilder: (context, index) {
            int posicao = index + 1;
            var dados = rankingGlobal[index];
            return _buildCardRanking(
              posicao, 
              dados['nome'] ?? 'Jogador', 
              dados['nivel'] ?? '', 
              dados['tempo'] ?? 0
            );
          },
        );
      },
    );
  }

  // --- ABA 2: PROGRESSO PESSOAL POR PERFIL ---
  Widget _buildAbaMeuProgresso(GameState gameState) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          "Perfil Ativo: ${gameState.perfil.toUpperCase()}",
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.neonCiano, fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          "Histórico de Conquistas (10 Fases / 10 Rodadas por Nível)",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 1,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          childAspectRatio: 3.5,
          children: Nivel.values.map((nivel) {
            final medalha = gameState.obterTipoMedalha(nivel.name);
            return _buildCardProgressoNivel(nivel, medalha);
          }).toList(),
        ),
      ],
    );
  }

  // --- COMPONENTES VISUAIS ---

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

  Widget _buildCardRanking(int posicao, String nomeUsuario, String nivelName, int tempoSegundos) {
    Color corPosicao = Colors.white;
    if (posicao == 1) corPosicao = Colors.amber;
    if (posicao == 2) corPosicao = Colors.grey.shade300;
    if (posicao == 3) corPosicao = Colors.brown.shade300;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: posicao == 1 ? Colors.amber.withOpacity(0.5) : Colors.white12,
          width: posicao == 1 ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                alignment: Alignment.center,
                child: Text("$posicaoº", style: TextStyle(color: corPosicao, fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nomeUsuario, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text("Nível: ${nivelName.toUpperCase()}", style: const TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.neonCiano.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text("$tempoSegundos s", style: const TextStyle(color: AppColors.neonCiano, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildCardProgressoNivel(Nivel nivel, String medalha) {
    bool conquistada = medalha.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: conquistada ? Colors.amber : Colors.white24, width: conquistada ? 2 : 1),
      ),
      child: Row(
        children: [
          Icon(nivel.icone, color: conquistada ? Colors.amber : Colors.white70, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  nivel.name.toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  conquistada ? "Conquista: $medalha" : "Status: Não Concluído",
                  style: TextStyle(color: conquistada ? AppColors.neonCiano : Colors.white54, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                const Text(
                  "Modo Treino: 10 Fases / 10 Rodadas",
                  style: TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNenhumDado(String mensagem) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Text(
            mensagem, 
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54, fontSize: 15)
          ),
        ),
      );
}