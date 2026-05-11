import '../models/game_state.dart';
import '../core/enums/nivel_enum.dart';

/// ===============================
/// CONTROLADOR PRINCIPAL DO JOGO
/// ===============================
class GameController {
  final GameState _state = GameState();

  GameState get state => _state;

  // =========================
  // RESPONDER (Lógica customizada por perfil)
  // =========================
  ResultadoResposta responder(bool correto, String perfil) {
    final String p = perfil.toLowerCase().trim();

    if (correto) {
      // 1. REGISTRA O ACERTO NO ESTADO
      _state.registrarAcerto();

      // 2. CALCULA PONTUAÇÃO POR PERFIL
      if (p == 'crianca') {
        // SUGESTÃO COMBO: 10, 20, 30, 40... conforme a pergunta atual na fase
        int combo = (_state.perguntaAtual + 1) * 10;
        _state.pontos += combo;
      } else {
        // Adulto e Professor ganham fixo (ou você pode manter 10)
        _state.pontos += 10;
      }

      // Avança a contagem de perguntas da fase
      _state.avancarPergunta();

      // Verifica se atingiu a meta de acertos da fase
      if (_state.faseCompleta()) {
        return ResultadoResposta.faseCompleta;
      }
      return ResultadoResposta.continuar;
      
    } else {
      // --- LÓGICA DE ERRO ---
      
      if (p == 'adulto' || p == 'professor') {
        // PENALIDADE: Perda de pontos real para perfis experientes
        _state.pontos -= 15;
        if (_state.pontos < 0) _state.pontos = 0;
      }

      // Reinicia o progresso da fase atual (obrigando a refazer)
      _state.resetFase(); 
      return ResultadoResposta.continuar;
    }
  }

  // =========================
  // GESTÃO DE ERRO / REINICIO
  // =========================
  
  void reiniciarFase() {
    _state.resetFase();
  }

  // =========================
  // PRÓXIMA FASE / SUBIR NÍVEL
  // =========================
  void proximaFase() {
    if (_state.fase < _state.fasesPorNivel) {
      _state.fase++;
      _state.resetFase(); 
    } else {
      _state.subirNivel();
      _state.fase = 1; 
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
  // NOMES DOS NÍVEIS
  // =====================================================

  String getNomeNivel() {
    switch (_state.nivel) {
      case Nivel.bronze:  return 'Bronze';
      case Nivel.prata:   return 'Prata';
      case Nivel.ouro:    return 'Ouro';
      case Nivel.platina: return 'Platina';
      case Nivel.mestre:  return 'Mestre';
    }
  }

  String getNomeNivelFormatado() {
    switch (_state.nivel) {
      case Nivel.bronze:  return '🥉 Bronze';
      case Nivel.prata:   return '🥈 Prata';
      case Nivel.ouro:    return '🥇 Ouro';
      case Nivel.platina: return '💎 Platina';
      case Nivel.mestre:  return '👑 Mestre';
    }
  }
}

enum ResultadoResposta {
  faseCompleta,
  continuar,
}