import '../models/game_state.dart';
import '../core/enums/nivel_enum.dart';

/// ===============================
/// CONTROLADOR PRINCIPAL DO JOGO
/// ===============================
///
/// Responsável por:
/// ✅ Pontuação
/// ✅ Avanço de perguntas
/// ✅ Avanço de fases
/// ✅ Avanço de níveis
/// ✅ Reset de fase
/// ✅ Reset total
///
class GameController {
  final GameState _state = GameState();

  GameState get state => _state;

  // =========================
  // RESPONDER
  // =========================
  ResultadoResposta responder(bool correto) {
    // =========================
    // ACERTOU
    // =========================
    if (correto) {
      _state.registrarAcerto();
    }

    // Avança pergunta
    _state.avancarPergunta();

    // =========================
    // FASE COMPLETA?
    // =========================
    if (_state.faseCompleta()) {
      return ResultadoResposta.faseCompleta;
    }

    return ResultadoResposta.continuar;
  }

  // =========================
  // ERRO
  // =========================
  void erro() {
    // Remove pontos da fase atual
    _state.removerPontosFase();

    // Reinicia progresso da fase
    _state.resetFase();
  }

  // =========================
  // REINICIAR FASE
  // =========================
  void reiniciarFase() {
    erro();
  }

  // =========================
  // PRÓXIMA FASE
  // =========================
  ///
  /// 🥉 Bronze -> fases 1 a 10
  /// 🥈 Prata -> fases 1 a 10
  /// 🥇 Ouro -> fases 1 a 10
  /// 💎 Platina -> fases 1 a 10
  /// 👑 Mestre -> fases 1 a 10
  ///
  /// Quando completa fase 10:
  /// ✅ sobe o nível
  /// ✅ volta fase para 1
  ///
  void proximaFase() {
    // =========================
    // AINDA TEM FASES NO NÍVEL
    // =========================
    if (_state.fase < _state.fasesPorNivel) {
      _state.fase++;

      // Reinicia perguntas da nova fase
      _state.resetFase();

      return;
    }

    // =========================
    // COMPLETOU O NÍVEL
    // =========================

    // sobe nível
    _state.subirNivel();

    // volta para fase 1
    _state.fase = 1;

    // reinicia perguntas
    _state.resetFase();
  }

  // =========================
  // RESET TOTAL
  // =========================
  void reiniciarJogo() {
    _state.resetJogo();
  }

  // =========================
  // NOME DO NÍVEL
  // =========================
  String getNomeNivel() {
    switch (_state.nivel) {
      case Nivel.bronze:
        return '🥉 Bronze';

      case Nivel.prata:
        return '🥈 Prata';

      case Nivel.ouro:
        return '🥇 Ouro';

      case Nivel.platina:
        return '💎 Platina';

      case Nivel.mestre:
        return '👑 Mestre';
    }
  }

  // =========================
  // PRÓXIMO NÍVEL
  // =========================
  String getProximoNivelNome() {
    switch (_state.nivel) {
      case Nivel.bronze:
        return '🥈 Prata';

      case Nivel.prata:
        return '🥇 Ouro';

      case Nivel.ouro:
        return '💎 Platina';

      case Nivel.platina:
        return '👑 Mestre';

      case Nivel.mestre:
        return '👑 Mestre';
    }
  }

  // =========================
  // COMPLETOU O NÍVEL?
  // =========================
  bool completouNivel() {
    return _state.fase >= _state.fasesPorNivel;
  }
}

/// ===============================
/// RESULTADO DA RESPOSTA
/// ===============================
enum ResultadoResposta {
  faseCompleta,
  continuar,
}