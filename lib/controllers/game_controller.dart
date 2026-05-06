import '../models/game_state.dart';

/// Controlador principal do fluxo do jogo.
/// Centraliza regras de pontuação, avanço de fases e resets.
class GameController {
  final GameState _state = GameState();

  GameState get state => _state;

  // =========================
  // RESPONDER
  // =========================
  ResultadoResposta responder(bool correto) {
    if (correto) {
      _state.registrarAcerto();
    }

    _state.avancarPergunta();

    // 🔥 sem gambiarra — estado controla limite
    return _state.faseCompleta()
        ? ResultadoResposta.faseCompleta
        : ResultadoResposta.continuar;
  }

  // =========================
  // ERRO
  // =========================
  void erro() {
    _state.removerPontosFase(); // 🔥 responsabilidade do model
    _state.resetFase();
  }

  // =========================
  // REINICIAR FASE
  // =========================
  void reiniciarFase() {
    erro(); // reaproveita regra
  }

  // =========================
  // PRÓXIMA FASE
  // =========================
  void proximaFase() {
    _state.fase++;
    _state.resetFase();
  }

  // =========================
  // RESET TOTAL
  // =========================
  void reiniciarJogo() {
    _state.resetJogo();
  }
}

/// Enum para controle de fluxo
enum ResultadoResposta {
  faseCompleta,
  continuar,
}