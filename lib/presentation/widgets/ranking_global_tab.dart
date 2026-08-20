// lib/presentation/widgets/ranking_global_tab.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/game_state.dart';

class RankingGlobalTab extends StatelessWidget {
  final Future<List<Map<String, dynamic>>> futureRanking;
  final VoidCallback onRefresh;

  const RankingGlobalTab({super.key, required this.futureRanking, required this.onRefresh});

  String _traduzirPerfil(String perfil, bool eIngles) {
    final p = perfil.trim().toLowerCase();
    if (!eIngles) return perfil.toUpperCase();
    
    if (p.contains('crianca') || p.contains('criança')) return 'CHILD';
    if (p.contains('adulto')) return 'ADULT';
    if (p.contains('professor')) return 'TEACHER';
    return perfil.toUpperCase();
  }

  String _formatarTempoAmigavel(int segundos) {
    if (segundos <= 0) return "0 s";
    if (segundos < 60) return "$segundos s";
    int min = segundos ~/ 60;
    int seg = segundos % 60;
    return seg == 0 ? "$min min" : "$min min $seg s";
  }

  @override
  Widget build(BuildContext context) {
    final gameState = context.watch<GameState>();
    final bool eIngles = gameState.currentLocale.languageCode == 'en';

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
              children: [
                const SizedBox(height: 100),
                Center(
                  child: Text(
                    eIngles ? "No records yet!" : "Nenhum recorde ainda!", 
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            );
          }
          
          final rankingGlobal = snapshot.data!;
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            itemCount: rankingGlobal.length,
            itemBuilder: (context, index) {
              int posicao = index + 1;
              var dados = rankingGlobal[index];
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: _buildCardRanking(
                    posicao, 
                    dados['nome'] ?? 'Jogador', 
                    dados['nivel'] ?? '', 
                    dados['perfil'] ?? '', 
                    dados['tempo'] ?? 0, 
                    dados['isMe'] ?? false,
                    eIngles,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCardRanking(int posicao, String nomeUsuario, String nivelName, String perfil, int tempoSegundos, bool isMe, bool eIngles) {
    // Cores e ícones de destaque para o pódio (1º, 2º e 3º)
    Color corBorda;
    Color corFundo;
    Widget iconePosicao;

    if (posicao == 1) {
      corBorda = const Color(0xFFFFD700); // Ouro vibrante
      corFundo = const Color(0xFFFFFDE7); // Amarelo bem claro
      iconePosicao = const Text("🥇", style: TextStyle(fontSize: 18));
    } else if (posicao == 2) {
      corBorda = const Color(0xFF90A4AE); // Prata
      corFundo = const Color(0xFFECEFF1); // Cinza claro
      iconePosicao = const Text("🥈", style: TextStyle(fontSize: 18));
    } else if (posicao == 3) {
      corBorda = const Color(0xFFD77A33); // Bronze
      corFundo = const Color(0xFFFBE9E7); // Laranja claro
      iconePosicao = const Text("🥉", style: TextStyle(fontSize: 18));
    } else {
      corBorda = isMe ? AppColors.neonCiano : Colors.black26;
      corFundo = isMe ? const Color(0xFFE0F7FA) : Colors.white.withOpacity(0.95);
      iconePosicao = SizedBox(
        width: 28, 
        child: Text(
          "$posicaoº", 
          style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      );
    }

    String perfilTraduzido = _traduzirPerfil(perfil, eIngles);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: corBorda.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: corBorda, width: (posicao <= 3 || isMe) ? 2.2 : 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 34,
                  child: Center(child: iconePosicao),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              perfilTraduzido.isNotEmpty ? "$nomeUsuario ($perfilTraduzido)" : nomeUsuario, 
                              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w900, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isMe) 
                            Container(
                              margin: const EdgeInsets.only(left: 6), 
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), 
                              decoration: BoxDecoration(color: AppColors.neonCiano, borderRadius: BorderRadius.circular(4)), 
                              child: Text(
                                eIngles ? "YOU" : "VOCÊ", 
                                style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        eIngles ? "Level: ${nivelName.toUpperCase()}" : "Nível: ${nivelName.toUpperCase()}", 
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), 
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.06), 
              borderRadius: BorderRadius.circular(8),
            ), 
            child: Text(
              _formatarTempoAmigavel(tempoSegundos), 
              style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}