// lib/domain/entities/pergunta_entity.dart

import 'package:meta/meta.dart';

/// Define os níveis de dificuldade como tipos constantes para evitar erros de String.
enum Dificuldade { facil, medio, dificil }

@immutable
class PerguntaEntity {
  final String id;
  final String enunciado;
  final List<String> opcoes;
  final String respostaCorreta;
  final Dificuldade dificuldade;
  final String? dica; // Adicionado para suporte ao Mascote Cal

  const PerguntaEntity({
    required this.id,
    required this.enunciado,
    required this.opcoes,
    required this.respostaCorreta,
    required this.dificuldade,
    this.dica,
  });

  /// Verifica a resposta aplicando sanitização de dados básica (Zero Trust).
  /// Compara ignorando espaços extras e variações de caixa (Case Insensitive).
  bool verificarResposta(String resposta) {
    return resposta.trim().toLowerCase() == respostaCorreta.trim().toLowerCase();
  }

  /// Método para criar cópias modificadas se necessário (Imutabilidade).
  PerguntaEntity copyWith({
    String? enunciado,
    List<String>? opcoes,
    String? respostaCorreta,
    Dificuldade? dificuldade,
    String? dica,
  }) {
    return PerguntaEntity(
      id: id,
      enunciado: enunciado ?? this.enunciado,
      opcoes: opcoes ?? this.opcoes,
      respostaCorreta: respostaCorreta ?? this.respostaCorreta,
      dificuldade: dificuldade ?? this.dificuldade,
      dica: dica ?? this.dica,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PerguntaEntity && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}