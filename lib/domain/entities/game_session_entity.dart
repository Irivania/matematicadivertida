// lib/domain/entities/game_session_entity.dart

import 'package:meta/meta.dart';

/// Entidade de Domínio que representa uma sessão de jogo única.
/// 
/// Seguindo o padrão de imutabilidade, esta classe protege as regras de negócio
/// contra alterações acidentais fora do fluxo controlado (BLoC/Notifier).
@immutable
class GameSessionEntity {
  final String id;
  final String userId;
  final int acertos;
  final int erros;
  final int vidasRestantes;
  final int xpGanho;
  final DateTime dataInicio;

  const GameSessionEntity({
    required this.id,
    required this.userId,
    this.acertos = 0,
    this.erros = 0,
    this.vidasRestantes = 3,
    this.xpGanho = 0,
    required this.dataInicio,
  });

  // Getters de lógica de negócio pura (Read-only)
  bool get isGameOver => vidasRestantes <= 0;
  double get precisao => acertos + erros == 0 ? 0 : (acertos / (acertos + erros)) * 100;

  /// Método central para evolução de estado. 
  /// Em 2026, evitamos setters para garantir consistência de dados.
  GameSessionEntity copyWith({
    int? acertos,
    int? erros,
    int? vidasRestantes,
    int? xpGanho,
  }) {
    return GameSessionEntity(
      id: id,
      userId: userId,
      acertos: acertos ?? this.acertos,
      erros: erros ?? this.erros,
      vidasRestantes: vidasRestantes ?? this.vidasRestantes,
      xpGanho: xpGanho ?? this.xpGanho,
      dataInicio: dataInicio,
    );
  }

  /// Lógica de Negócio: Calcula o impacto de um acerto
  GameSessionEntity registrarAcerto(int pontos) {
    return copyWith(
      acertos: acertos + 1,
      xpGanho: xpGanho + pontos,
    );
  }

  /// Lógica de Negócio: Calcula o impacto de um erro
  GameSessionEntity registrarErro() {
    final novasVidas = vidasRestantes - 1;
    return copyWith(
      erros: erros + 1,
      vidasRestantes: novasVidas < 0 ? 0 : novasVidas,
    );
  }
}