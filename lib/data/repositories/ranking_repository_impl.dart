import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/ranking_entry_entity.dart';
import '../../domain/repositories/i_ranking_repository.dart';

class RankingRepositoryImpl implements IRankingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<RankingEntryEntity>> getTopRanking({int limit = 10}) async {
    // Consulta otimizada: ordena por xp_total e limita o resultado
    final snapshot = await _firestore
        .collection('users')
        .orderBy('xp_total', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value.data();
      
      return RankingEntryEntity(
        userId: entry.value.id,
        nome: data['nome'] ?? 'Jogador Misterioso',
        fotoUrl: data['fotoUrl'],
        xp: data['xp_total'] ?? 0,
        posicao: index + 1, // A posição é o índice + 1
      );
    }).toList();
  }
}