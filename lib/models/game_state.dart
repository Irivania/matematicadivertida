import '../core/enums/nivel_enum.dart';

// =========================
// MODELO DE ESTADO
// =========================
class GameState {
  int fase = 1;
  int perguntaAtual = 0;
  int pontos = 0;
  int acertos = 0;

  // 🔥 NÍVEL DO JOGADOR
  Nivel nivel = Nivel.bronze;

  // 🔥 controle da fase atual
  int pontosFase = 0;

  // =========================
  // RESET FASE
  // =========================
  void resetFase() {
    perguntaAtual = 0;
    acertos = 0;
    pontosFase = 0;
  }

  // =========================
  // RESET TOTAL
  // =========================
  void resetJogo() {
    fase = 1;
    perguntaAtual = 0;
    pontos = 0;
    acertos = 0;
    pontosFase = 0;

    // 🔥 reseta nível também
    nivel = Nivel.bronze;
  }

  // =========================
  // ACERTO
  // =========================
  void registrarAcerto() {
    acertos++;
    pontos += 10;
    pontosFase += 10;
  }

  // =========================
  // AVANÇAR PERGUNTA
  // =========================
  void avancarPergunta() {
    if (perguntaAtual < 10) {
      perguntaAtual++;
    }
  }

  // =========================
  // REMOVER PONTOS DA FASE
  // =========================
  void removerPontosFase() {
    pontos -= pontosFase;

    if (pontos < 0) {
      pontos = 0;
    }

    pontosFase = 0;
  }

  // =========================
  // FASE COMPLETA
  // =========================
  bool faseCompleta() {
    return perguntaAtual >= 10;
  }

  // =========================
  // 🔥 EVOLUÇÃO DE NÍVEL
  // =========================
  void subirNivel() {
    switch (nivel) {
      case Nivel.bronze:
        nivel = Nivel.prata;
        break;
      case Nivel.prata:
        nivel = Nivel.ouro;
        break;
      case Nivel.ouro:
        nivel = Nivel.platina;
        break;
      case Nivel.platina:
        nivel = Nivel.mestre;
        break;
      case Nivel.mestre:
        break;
    }
  }
}