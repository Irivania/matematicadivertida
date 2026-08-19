import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class RankingGlobalTab extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> futureRanking;
  final VoidCallback onRefresh;

  const RankingGlobalTab({super.key, required this.futureRanking, required this.onRefresh});

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
      backgroundColor: Colors.white,
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
                Center(child: Text("Nenhum recorde ainda!", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
              ],
            );
          }
          
          final rankingGlobal = snapshot.data!;
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            // Padding lateral maior para não ir de canto a canto
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: rankingGlobal.length,
            itemBuilder: (context, index) {
              int posicao = index + 1;
              var dados = rankingGlobal[index];
              return Center( // Envolvemos em Center para limitar a largura
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: _buildCardRanking(posicao, dados['nome'] ?? 'Jogador', dados['nivel'] ?? '', dados['tempo'] ?? 0, dados['isMe'] ?? false),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCardRanking(int posicao, String nomeUsuario, String nivelName, int tempoSegundos, bool isMe) {
    Color corPosicao = (posicao == 1) ? const Color(0xFFB8860B) : (posicao == 2 ? const Color(0xFF6E6E6E) : (posicao == 3 ? const Color(0xFFA0522D) : Colors.black87));

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFFE0F7FA) : Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isMe ? AppColors.neonCiano : Colors.black26, width: isMe ? 2.0 : 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(width: 28, child: Text("$posicaoº", style: TextStyle(color: corPosicao, fontWeight: FontWeight.w900, fontSize: 16))),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(nomeUsuario, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14)),
                      if (isMe) Container(margin: const EdgeInsets.only(left: 6), padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1), decoration: BoxDecoration(color: AppColors.neonCiano, borderRadius: BorderRadius.circular(4)), child: const Text("VOCÊ", style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold))),
                    ],
                  ),
                  Text("Nível: ${nivelName.toUpperCase()}", style: const TextStyle(color: Colors.black87, fontSize: 11, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.black.withOpacity(0.06), borderRadius: BorderRadius.circular(6)), child: Text(_formatarTempoAmigavel(tempoSegundos), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12))),
        ],
      ),
    );
  }
}