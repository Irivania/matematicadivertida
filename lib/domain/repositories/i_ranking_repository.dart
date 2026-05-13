import '../entities/ranking_entry_entity.dart';

abstract class IRankingRepository {
  /// Busca os top [limit] usuários ordenados por XP
  Future<List<RankingEntryEntity>> getTopRanking({int limit = 10});
}