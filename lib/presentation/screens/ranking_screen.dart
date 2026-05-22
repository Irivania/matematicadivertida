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

    // Transforma o mapa em lista e ordena pelo menor tempo
    final listaRanking = recordes.entries.toList();
    listaRanking.sort((a, b) => a.value.compareTo(b.value));

    return Scaffold(
      body: Stack(
        children: [
          // Imagem de fundo ajustada para não cortar o topo
          Positioned.fill(
            child: Image.asset(
              'assets/images/imagem_fundo_ranking.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter, 
            ),
          ),

          // Camada de iluminação suave
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.05),
            ),
          ),

          // Posicionamento e centralização do Painel do Ranking
          SafeArea(
            child: Center(
              child: SingleChildScrollView( 
                child: Padding(
                  padding: const EdgeInsets.only(top: 240, bottom: 40, left: 24, right: 24),
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: 500, 
                    ),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85), 
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "RANKING GLOBAL • MODO DISPUTA",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.blueGrey.shade900,
                            fontSize: 18, 
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Menores Tempos por Ranking Global",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 12),
                        ),
                        const SizedBox(height: 16),

                        // Lista de Recordes
                        listaRanking.isEmpty
                            ? _buildNenhumDado()
                            : ListView.builder(
                                itemCount: listaRanking.length,
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                shrinkWrap: true, 
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  final item = listaRanking[index];
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

          // Botão Sair limpo no topo esquerdo
          Positioned(
            top: MediaQuery.of(context).padding.top + 15,
            left: 15,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.neonCiano, width: 2),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text(
                      "SAIR", 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNenhumDado() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart_rounded, size: 45, color: Colors.blueGrey.withOpacity(0.4)),
          const SizedBox(height: 10),
          const Text(
            "NENHUM REGISTRO",
            style: TextStyle(color: Colors.blueGrey, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildCardRanking(int posicao, String nivelName, int tempoSegundos, GameState state) {
    Nivel? nivelEnum;
    try {
      nivelEnum = Nivel.values.firstWhere((e) => e.name == nivelName.toLowerCase().trim());
    } catch (_) {}

    final String labelExibicao = nivelEnum != null ? nivelEnum.label : nivelName.toUpperCase();
    final String dataRecorde = state.obterDataDoRecorde(nivelName);
    final String nomeJogador = state.perfil.toUpperCase();

    // Lógica das Medalhas Dinâmicas
    final String tipoMedalha = state.obterTipoMedalha(tempoSegundos);
    Color corMedalha = Colors.brown; // Cor padrão bronze
    if (tipoMedalha == "ouro") {
      corMedalha = Colors.amber;
    } else if (tipoMedalha == "prata") {
      corMedalha = Colors.blueGrey.shade300;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5), 
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withOpacity(0.6), 
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: corMedalha.withOpacity(0.6),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Medalha Dinâmica
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: corMedalha.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: corMedalha, width: 2),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.emoji_events, color: corMedalha, size: 20),
          ),
          const SizedBox(width: 12),

          // Nome do Jogador, Ícone e Subtítulo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (nivelEnum != null) ...[
                      Icon(nivelEnum.icone, color: nivelEnum.cor, size: 16),
                      const SizedBox(width: 5),
                    ],
                    Expanded(
                      child: Text(
                        "[$nomeJogador] Rank $labelExibicao",
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.blueGrey.shade900, 
                          fontSize: 14, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  "Recorde batido em: $dataRecorde", 
                  style: TextStyle(color: Colors.blueGrey.shade500, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Bloco do Cronômetro / Tempo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade900,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer, color: Colors.white, size: 12),
                const SizedBox(width: 4),
                Text(
                  state.formatarMinutos(tempoSegundos), 
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}