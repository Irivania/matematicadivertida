class Pergunta {
  final String pergunta;
  final String resposta;
  final String tipo; // ex: 'basica', 'equacao', 'porcentagem'
  final String dica; // Dica pedagógica ou regra de PEMDAS

  Pergunta({
    required this.pergunta,
    required this.resposta,
    required this.tipo,
    required this.dica,
  });

  /// Converte um mapa (JSON/Firestore) para uma instância de Pergunta.
  factory Pergunta.fromMap(Map<String, dynamic> map) {
    return Pergunta(
      pergunta: map['pergunta'] ?? '',
      resposta: map['resposta'] ?? '',
      tipo: map['tipo'] ?? '',
      dica: map['dica'] ?? 'Analise com calma e resolva!',
    );
  }

  /// Converte a instância de Pergunta para um mapa.
  Map<String, dynamic> toMap() {
    return {
      'pergunta': pergunta,
      'resposta': resposta,
      'tipo': tipo,
      'dica': dica,
    };
  }

  /// Cria uma cópia da pergunta alterando apenas campos específicos.
  /// Útil se você quiser, por exemplo, traduzir uma dica em tempo real.
  Pergunta copyWith({
    String? pergunta,
    String? resposta,
    String? tipo,
    String? dica,
  }) {
    return Pergunta(
      pergunta: pergunta ?? this.pergunta,
      resposta: resposta ?? this.resposta,
      tipo: tipo ?? this.tipo,
      dica: dica ?? this.dica,
    );
  }

  @override
  String toString() {
    return 'Pergunta(pergunta: $pergunta, resposta: $resposta, tipo: $tipo)';
  }
}