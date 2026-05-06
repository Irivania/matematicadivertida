import '../models/game_state.dart';

class GameController {
  final GameState state = GameState();

  bool responder(bool correto) {
    if (correto) {
      state.registrarAcerto();
    }

    state.avancarPergunta();

    return state.faseCompleta();
  }

  void erro() {
    state.avancarPergunta();
  }

  void reiniciarFase() {
    state.resetFase();
  }

  void proximaFase() {
    state.fase++;
    state.resetFase();
  }

  void reiniciarJogo() {
    state.resetJogo();
  }
}