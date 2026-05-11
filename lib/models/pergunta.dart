class Pergunta {
  final String pergunta;
  final String resposta;
  final String tipo;
  final String dica; // <-- Novo campo

  Pergunta({
    required this.pergunta,
    required this.resposta,
    required this.tipo,
    required this.dica, // <-- Inclua no construtor
  });
}