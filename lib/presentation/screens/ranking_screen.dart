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
                  // CORREÇÃO DO TOPO: Aumentamos o recuo superior para 240. 
                  // Isso empurra o painel para baixo, tirando-o de cima do letreiro "Matemática Divertida"!
                  padding: const EdgeInsets.only(top: 240, bottom: 40, left: 24, right: 24),
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: 500, // Mantém a largura compacta ideal
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
                      mainAxisSize: MainAxisSize.min, // O container se molda e cresce para baixo dinamicamente
                      children: [
                        // Título interno
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
                                shrinkWrap: true, // Gasta apenas a altura real das linhas
                                physics: const NeverScrollableScrollPhysics(), // Evita conflitos de rolagem
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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5), 
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withOpacity(0.6), 
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: posicao == 1 ? Colors.amber.shade400 : Colors.blue.shade200.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Medalha / Círculo de Posição
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: posicao == 1 ? Colors.amber.shade100 : Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: posicao == 1
                ? const Icon(Icons.workspace_premium, color: Colors.amber, size: 18)
                : Text(
                    "$posicaoº",
                    style: TextStyle(
                      color: Colors.blueGrey.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
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