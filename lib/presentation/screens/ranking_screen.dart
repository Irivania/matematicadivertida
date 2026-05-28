// lib/presentation/screens/ranking_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/game_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/enums/nivel_enum.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameState>().carregarRecordesLocais();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final recordes = gameState.recordesPorNivel;
    final listaRanking = recordes.entries.toList();
    listaRanking.sort((a, b) => a.value.compareTo(b.value));

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/imagem_fundo_ranking.png', fit: BoxFit.cover, alignment: Alignment.topCenter),
          ),
          Positioned.fill(child: Container(color: Colors.black.withOpacity(0.6))),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 80, bottom: 40, left: 24, right: 24),
              child: Column(
                children: [
                  // --- SEÇÃO RANKING ---
                  _buildSectionTitle("RANKING GLOBAL"),
                  listaRanking.isEmpty ? _buildNenhumDado() : Column(
                    children: listaRanking.asMap().entries.map((e) => _buildCardRanking(e.key + 1, e.value.key, e.value.value, gameState)).toList(),
                  ),

                  const SizedBox(height: 40),

                  // --- SEÇÃO CONQUISTAS (Medalhas) ---
                  _buildSectionTitle("MINHAS CONQUISTAS"),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: Nivel.values.map((nivel) {
                      final medalha = gameState.obterTipoMedalha(nivel.name);
                      return _buildMedalhaCard(nivel, medalha);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          
          _buildBotaoSair(context),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) => Text(title, 
      style: const TextStyle(color: AppColors.neonCiano, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.5));

  Widget _buildMedalhaCard(Nivel nivel, String medalha) {
    bool conquistada = medalha.isNotEmpty;
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(15), border: Border.all(color: conquistada ? Colors.amber : Colors.white24)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(nivel.icone, color: conquistada ? nivel.cor : Colors.grey, size: 30),
          const SizedBox(height: 5),
          Text(medalha.isNotEmpty ? medalha.split(" ").last : "LOCKED", 
               style: TextStyle(color: conquistada ? Colors.white : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBotaoSair(BuildContext context) => Positioned(
    top: 40, left: 15,
    child: InkWell(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(30), border: Border.all(color: AppColors.neonCiano, width: 2)),
        child: const Row(children: [Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 14), SizedBox(width: 6), Text("SAIR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
      ),
    ),
  );

  Widget _buildCardRanking(int posicao, String nivelName, int tempoSegundos, GameState state) {
    // ... (seu método _buildCardRanking continua aqui, sem alterações)
    return Container(); // Placeholder para manter sua lógica original
  }

  Widget _buildNenhumDado() => const Text("Nenhum registro ainda!", style: TextStyle(color: Colors.white54));
}