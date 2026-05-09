import '../models/game_state.dart';
import '../core/enums/nivel_enum.dart';

/// ===============================
/// CONTROLADOR PRINCIPAL DO JOGO
/// ===============================
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

    // Avança a contagem de perguntas da fase atual
    _state.avancarPergunta();

    // Verifica se atingiu a meta de acertos da fase
    if (_state.faseCompleta()) {
      return ResultadoResposta.faseCompleta;
    }

    return ResultadoResposta.continuar;
  }

  // =========================
  // ERRO
  // =========================
  void erro() {
    _state.removerPontosFase();
    _state.resetFase();
  }

  void reiniciarFase() {
    erro();
  }

  // =========================
  // PRÓXIMA FASE
  // =========================
  void proximaFase() {
    // Se ainda não chegou na última fase do nível (ex: fase 10)
    if (_state.fase < _state.fasesPorNivel) {
      _state.fase++;
      _state.resetFase(); // Reseta o contador de perguntas para a nova fase
    } else {
      // Se completou a fase 10, sobe o nível (Bronze -> Prata...)
      _state.subirNivel();
      _state.fase = 1; // Volta para a fase 1 do novo nível
      _state.resetFase();
    }
  }

  // =========================
  // RESET TOTAL
  // =========================
  void reiniciarJogo() {
    _state.resetJogo();
  }

  // =====================================================
  // NOME DO NÍVEL (Ajustado para o PerguntaService)
  // =====================================================
  // Removi os emojis para que o 'switch' do Service funcione sem erros
  String getNomeNivel() {
    switch (_state.nivel) {
      case Nivel.bronze: return 'Bronze';
      case Nivel.prata:  return 'Prata';
      case Nivel.ouro:   return 'Ouro';
      case Nivel.platina:return 'Platina';
      case Nivel.mestre: return 'Mestre';
    }
  }

  // Nome formatado para mostrar na interface (Com Emojis)
  String getNomeNivelFormatado() {
    switch (_state.nivel) {
      case Nivel.bronze: return '🥉 Bronze';
      case Nivel.prata:  return '🥈 Prata';
      case Nivel.ouro:   return '🥇 Ouro';
      case Nivel.platina:return '💎 Platina';
      case Nivel.mestre: return '👑 Mestre';
    }
  }

  // =========================
  // PRÓXIMO NÍVEL
  // =========================
  String getProximoNivelNome() {
    switch (_state.nivel) {
      case Nivel.bronze: return 'Prata';
      case Nivel.prata:  return 'Ouro';
      case Nivel.ouro:   return 'Platina';
      case Nivel.platina:return 'Mestre';
      case Nivel.mestre: return 'Mestre';
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