// lib/presentation/screens/ranking_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/game_state.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/enums/nivel_enum.dart'; // Importa seu enum para mapear ícones e labels

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  @override
  void initState() {
    super.initState();
    // Força o carregamento dos dados de teste/locais ao abrir a tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameState>().carregarRecordesLocais();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Escuta o GameState reativamente
    final gameState = context.watch<GameState>();
    final recordes = gameState.recordesPorNivel;

    // Transforma o mapa de recordes em uma lista ordenada pelo menor tempo (mais rápido)
    final listaRanking = recordes.entries.toList();
    listaRanking.sort((a, b) => a.value.compareTo(b.value));

    return Scaffold(
      backgroundColor: AppColors.backgroundEscuro,
      body: Stack(
        children: [
          // Fundo Estilizado com Neon Roxo/Disputa
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.backgroundEscuro,
                    Colors.purple.withOpacity(0.12),
                    AppColors.backgroundEscuro,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 80),
                
                // Cabeçalho Principal
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.amber, size: 36),
                    const SizedBox(width: 10),
                    Text(
                      "RANKING GLOBAL",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(color: Colors.purple.withOpacity(0.8), blurRadius: 10)
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "Modo Disputa • Menores Tempos por Rank",
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                ),
                const SizedBox(height: 25),

                // Conteúdo Condicional (Lista ou Mensagem Vazia)
                Expanded(
                  child: listaRanking.isEmpty
                      ? _buildNenhumDado()
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: listaRanking.length,
                          itemBuilder: (context, index) {
                            final item = listaRanking[index];
                            return _buildCardRanking(index + 1, item.key, item.value);
                          },
                        ),
                ),
              ],
            ),
          ),

          // Botão Voltar superior esquerdo padrão
          Positioned(
            top: MediaQuery.of(context).padding.top + 15,
            left: 15,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.neonCiano, width: 2),
                  boxShadow: [
                    BoxShadow(color: AppColors.neonCiano.withOpacity(0.3), blurRadius: 8)
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 13),
                    SizedBox(width: 6),
                    Text(
                      "VOLTAR", 
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1)
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_rounded, size: 70, color: Colors.white.withOpacity(0.15)),
            const SizedBox(height: 15),
            const Text(
              "NENHUM DADO ENCONTRADO",
              style: TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Complete uma fase no Modo Disputa na tela de jogo para registrar seu primeiro recorde de velocidade!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardRanking(int posicao, String nivelName, int tempoSegundos) {
    // Tenta encontrar o Enum correspondente à string para extrair o ícone e a label corretas
    Nivel? nivelEnum;
    try {
      nivelEnum = Nivel.values.firstWhere((e) => e.name == nivelName);
    } catch (_) {}

    // CORREÇÃO DOS TIPOS: Forçado o cast/conversão para String usando .toString() para evitar o erro de compilação
    final String labelExibicao = nivelEnum != null ? nivelEnum.label.toString() : nivelName.toUpperCase();
    final String iconeExibicao = nivelEnum != null ? nivelEnum.icone.toString() : "🎯";

    // Define cores estilizadas para o pódio (1º, 2º e 3º lugar)
    Color corTrofeu = Colors.transparent;
    if (posicao == 1) corTrofeu = Colors.amber;
    if (posicao == 2) corTrofeu = const Color(0xFFC0C0C0); // Prata
    if (posicao == 3) corTrofeu = const Color(0xCD7F323A); // Bronze

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 7),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: posicao == 1 ? Colors.amber.withOpacity(0.4) : Colors.purpleAccent.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Indicador de Posição / Medalha
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: corTrofeu != Colors.transparent ? corTrofeu.withOpacity(0.15) : Colors.white10,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: corTrofeu != Colors.transparent && posicao == 1
                ? Icon(Icons.workspace_premium, color: corTrofeu, size: 22)
                : Text(
                    "$posicaoº",
                    style: TextStyle(
                      color: corTrofeu != Colors.transparent ? corTrofeu : Colors.white60,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
          ),
          const SizedBox(width: 15),

          // Informações do Nível atingido
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$iconeExibicao Rank $labelExibicao",
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                "Recorde Pessoal",
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
              ),
            ],
          ),
          const Spacer(),

          // Tempo Registrado
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.purpleAccent.withOpacity(0.4), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timer_sharp, color: Colors.purpleAccent, size: 14),
                const SizedBox(width: 4),
                Text(
                  "${tempoSegundos}s",
                  style: const TextStyle(color: Colors.purpleAccent, fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}