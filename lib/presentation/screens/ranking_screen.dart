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
    
    // FILTRAGEM: Pega apenas os recordes que correspondem ao perfil ativo (ex: bronze_crianca)
    // O carregarRecordesLocais já deve estar filtrando ou o nome da chave deve conter o perfil.
    final recordes = gameState.recordesPorNivel;

    // Converte para lista e ordena
    final listaRanking = recordes.entries.toList();
    listaRanking.sort((a, b) => a.value.compareTo(b.value));

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/imagem_fundo_ranking.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter, 
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.white.withOpacity(0.05)),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView( 
                child: Padding(
                  padding: const EdgeInsets.only(top: 240, bottom: 40, left: 24, right: 24),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85), 
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))
                      ],
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("RANKING GLOBAL: ${gameState.perfil.toUpperCase()}", 
                             textAlign: TextAlign.center, 
                             style: TextStyle(color: Colors.blueGrey.shade900, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                        const SizedBox(height: 16),
                        listaRanking.isEmpty
                            ? _buildNenhumDado()
                            : ListView.builder(
                                itemCount: listaRanking.length,
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                shrinkWrap: true, 
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final item = listaRanking[index];
                                  // O index + 1 define a posição no ranking
                                  return _buildCardRanking(index + 1, item.key, item.value, gameState);
                                },
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 15,
            left: 15,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(30), border: Border.all(color: AppColors.neonCiano, width: 2)),
                child: const Row(children: [Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 14), SizedBox(width: 6), Text("SAIR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNenhumDado() {
    return const Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        children: [
          Icon(Icons.bar_chart_rounded, size: 45, color: Colors.blueGrey),
          SizedBox(height: 10),
          Text("NENHUM REGISTRO PARA ESTE PERFIL", style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCardRanking(int posicao, String nivelName, int tempoSegundos, GameState state) {
    // Busca o nome do recordista salvo no mapa de nomes
    final String nomeDoRecordista = state.nomesRecordesPorNivel[nivelName.toLowerCase()] ?? "JOGADOR";
    final String dataRecorde = state.obterDataDoRecorde(nivelName);

    // Identifica o nível para o ícone
    Nivel? nivelEnum;
    try {
      nivelEnum = Nivel.values.firstWhere((e) => e.name == nivelName.toLowerCase().trim());
    } catch (_) {}

    final String labelExibicao = nivelEnum != null ? nivelEnum.label : nivelName.toUpperCase();
    
    // Cor da medalha baseada no tempo
    final String tipoMedalha = state.obterTipoMedalha(tempoSegundos);
    Color corMedalha = tipoMedalha == "ouro" ? Colors.amber : (tipoMedalha == "prata" ? Colors.blueGrey.shade300 : Colors.brown);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5), 
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: Colors.blue.shade50.withOpacity(0.6), borderRadius: BorderRadius.circular(14), border: Border.all(color: corMedalha.withOpacity(0.6), width: 1.5)),
      child: Row(
        children: [
          // Exibição da posição (1º, 2º, 3º...)
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: corMedalha.withOpacity(0.2), shape: BoxShape.circle, border: Border.all(color: corMedalha, width: 2)),
            alignment: Alignment.center,
            child: Text("$posicaoº", style: TextStyle(color: corMedalha, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "[$nomeDoRecordista] - $labelExibicao",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.blueGrey.shade900, fontSize: 14, fontWeight: FontWeight.bold),
                ),
                Text("Batido em: $dataRecorde", style: TextStyle(color: Colors.blueGrey.shade500, fontSize: 10)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: Colors.blueGrey.shade900, borderRadius: BorderRadius.circular(10)),
            child: Text(state.formatarMinutos(tempoSegundos), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}