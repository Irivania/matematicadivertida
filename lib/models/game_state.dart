class GameState {
  int fase = 1;
  int perguntaAtual = 0;
  int pontos = 0;
  int acertos = 0;

  void resetFase() {
    perguntaAtual = 0;
    acertos = 0;
  }

  void resetJogo() {
    fase = 1;
    perguntaAtual = 0;
    pontos = 0;
    acertos = 0;
  }

  void registrarAcerto() {
    acertos++;
    pontos += 10;
  }

  void avancarPergunta() {
    perguntaAtual++;
  }

  bool faseCompleta() {
    return perguntaAtual >= 10;
  }
}