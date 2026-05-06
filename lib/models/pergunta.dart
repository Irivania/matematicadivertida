class Pergunta {
  final String pergunta;
  final String resposta;
  final List<String>? opcoes;
  final String tipo;

  const Pergunta({
    required this.pergunta,
    required this.resposta,
    this.opcoes,
    required this.tipo,
  });
}