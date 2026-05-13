class CalcularPontuacaoUseCase {
  int executar(int acertos, String dificuldade) {
    int base = acertos * 10;
    if (dificuldade == 'dificil') return base * 2;
    return base;
  }
}