class GameSessionEntity {
  final String id;
  final String userId;
  int acertos;
  int erros;
  int vidasRestantes;
  DateTime dataInicio;

  GameSessionEntity({
    required this.id,
    required this.userId,
    this.acertos = 0,
    this.erros = 0,
    this.vidasRestantes = 3,
    required this.dataInicio,
  });

  bool get isGameOver => vidasRestantes <= 0;
}