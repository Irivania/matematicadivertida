import 'package:flutter/material.dart';
import '../../data/repositories/ranking_repository_impl.dart';
import '../../domain/entities/ranking_entry_entity.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rankingRepo = RankingRepositoryImpl();

    return Scaffold(
      appBar: AppBar(title: const Text("🏆 Ranking Global")),
      body: FutureBuilder<List<RankingEntryEntity>>(
        future: rankingRepo.getTopRanking(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Nenhum dado encontrado."));
          }

          final ranking = snapshot.data!;

          return ListView.builder(
            itemCount: ranking.length,
            itemBuilder: (context, index) {
              final user = ranking[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getPosicaoColor(user.posicao),
                  child: Text("${user.posicao}º", style: const TextStyle(color: Colors.white)),
                ),
                title: Text(user.nome),
                subtitle: Text("${user.xp} XP"),
                trailing: user.posicao <= 3 ? const Icon(Icons.emoji_events, color: Colors.amber) : null,
              );
            },
          );
        },
      ),
    );
  }

  Color _getPosicaoColor(int posicao) {
    if (posicao == 1) return Colors.amber; // Ouro
    if (posicao == 2) return Colors.grey;  // Prata
    if (posicao == 3) return Colors.brown; // Bronze
    return Colors.indigo;
  }
}