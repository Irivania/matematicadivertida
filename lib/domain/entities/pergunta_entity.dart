class PerguntaEntity {
  final String id;
  final String enunciado;
  final List<String> opcoes;
  final String respostaCorreta;
  final String dificuldade; // 'facil', 'medio', 'dificil'

  PerguntaEntity({
    required this.id,
    required this.enunciado,
    required this.opcoes,
    required this.respostaCorreta,
    required this.dificuldade,
  });

  bool verificarResposta(String resposta) {
    return resposta == respostaCorreta;
  }
}