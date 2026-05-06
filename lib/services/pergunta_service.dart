import 'dart:math';
import '../models/pergunta.dart';

class PerguntaService {
  final Random rand = Random();

  Pergunta gerarSimples() {
    int a = rand.nextInt(10) + 1;
    int b = rand.nextInt(10) + 1;

    return Pergunta(
      pergunta: "Quanto é $a + $b ?",
      resposta: (a + b).toString(),
      tipo: "adicao",
    );
  }
}