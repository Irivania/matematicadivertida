// lib/presentation/widgets/ranking_global_tab.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class RankingGlobalTab extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> futureRanking;
  final VoidCallback onRefresh;

  const RankingGlobalTab({
    super.key, 
    required this.futureRanking,
    required this.onRefresh,
  });

  String _formatarTempoAmigavel(int segundos) {
    if (segundos <= 0) return "0 s";
    if (segundos < 60) return "$segundos s";
    int min = segundos ~/ 60;
    int seg = segundos % 60;
    return seg == 0 ? "$min min" : "$min min $seg s";
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.neonCiano,
      backgroundColor: Colors.black,
      onRefresh: () async => onRefresh(),
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: futureRanking,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.neonCiano));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 100),
                Center(
                  child: Text("Nenhum recorde no Modo Disputa ainda!\nPuxe para baixo para atualizar", 
                    textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 15)
                  ),
                ),
              ],
            );
          }
          
          final rankingGlobal = snapshot.data!;
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            itemCount: rankingGlobal.length,
            itemBuilder: (context, index) {
              int posicao = index + 1;
              var dados = rankingGlobal[index];
              return _buildCardRanking(
                posicao, 
                dados['nome'] ?? 'Jogador', 
                dados['nivel'] ?? '', 
                dados['tempo'] ?? 0,
                dados['isMe'] ?? false, // Identifica se é o usuário logado
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCardRanking(int posicao, String nomeUsuario, String nivelName, int tempoSegundos, bool isMe) {
    Color corPosicao = Colors.white;
    if (posicao == 1) corPosicao = Colors.amber;
    if (posicao == 2) corPosicao = Colors.grey.shade300;
    if (posicao == 3) corPosicao = Colors.brown.shade300;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        // Se for o próprio usuário, destacamos o fundo com um tom de ciano transparente
        color: isMe ? AppColors.neonCiano.withOpacity(0.18) : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          // Se for o usuário, a borda fica forte em ciano; se for o 1º lugar, fica dourada
          color: isMe ? AppColors.neonCiano : (posicao == 1 ? Colors.amber.withOpacity(0.5) : Colors.white12),
          width: isMe ? 1.8 : 1.0,
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
                  Row(
                    children: [
                      Text(nomeUsuario, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      if (isMe) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.neonCiano,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text("VOCÊ", style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text("Nível: ${nivelName.toUpperCase()}", style: const TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: AppColors.neonCiano.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Text(_formatarTempoAmigavel(tempoSegundos), style: const TextStyle(color: AppColors.neonCiano, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}