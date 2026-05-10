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

    // Avança a contagem de perguntas (tentativas) da fase atual
    _state.avancarPergunta();

    // Verifica se atingiu a meta de acertos da fase (ex: acertar 5 de 5)
    if (_state.faseCompleta()) {
      return ResultadoResposta.faseCompleta;
    }

    return ResultadoResposta.continuar;
  }

  // =========================
  // GESTÃO DE ERRO
  // =========================
  void erro() {
    _state.removerPontosFase();
    _state.resetFase(); // Reseta o progresso interno da fase atual
  }

  void reiniciarFase() {
    erro();
  }

  // =========================
  // PRÓXIMA FASE / SUBIR NÍVEL
  // =========================
  void proximaFase() {
    // Se ainda não chegou na última fase do nível (ex: fase 10)
    if (_state.fase < _state.fasesPorNivel) {
      _state.fase++;
      _state.resetFase(); // Reseta o contador de perguntas para a nova fase
    } else {
      // Se completou a última fase, sobe o nível (Bronze -> Prata...)
      _state.subirNivel();
      _state.fase = 1; // Reinicia na fase 1 do novo nível
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
  // NOMES DOS NÍVEIS (Integração com Service e UI)
  // =====================================================

  /// Retorna apenas o nome puro para o 'switch' do PerguntaService
  String getNomeNivel() {
    switch (_state.nivel) {
      case Nivel.bronze:  return 'Bronze';
      case Nivel.prata:   return 'Prata';
      case Nivel.ouro:    return 'Ouro';
      case Nivel.platina: return 'Platina';
      case Nivel.mestre:  return 'Mestre';
    }
  }

  /// Retorna o nome decorado para exibir na interface do usuário (HUD)
  String getNomeNivelFormatado() {
    switch (_state.nivel) {
      case Nivel.bronze:  return '🥉 Bronze';
      case Nivel.prata:   return '🥈 Prata';
      case Nivel.ouro:    return '🥇 Ouro';
      case Nivel.platina: return '💎 Platina';
      case Nivel.mestre:  return '👑 Mestre';
    }
  }

  /// Auxiliar para mostrar qual o próximo desafio ao usuário
  String getProximoNivelNome() {
    switch (_state.nivel) {
      case Nivel.bronze:  return 'Prata';
      case Nivel.prata:   return 'Ouro';
      case Nivel.ouro:    return 'Platina';
      case Nivel.platina: return 'Mestre';
      case Nivel.mestre:  return 'Mestre Máximo';
    }
  }

  // =========================
  // STATUS DE PROGRESSO
  // =========================
  
  /// Verifica se o jogador terminou todas as fases do nível atual
  bool completouNivel() {
    return _state.fase >= _state.fasesPorNivel;
  }
}

/// ===============================
/// ENUM DE RESULTADO
/// ===============================
enum ResultadoResposta {
  faseCompleta,
  continuar,
}