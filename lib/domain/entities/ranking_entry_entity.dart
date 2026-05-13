class RankingEntryEntity {
  final String userId;
  final String nome;
  final String? fotoUrl;
  final int xp;
  final int posicao;

  const RankingEntryEntity({
    required this.userId,
    required this.nome,
    this.fotoUrl,
    required this.xp,
    required this.posicao,
  });
}