import '../core/enums/nivel_enum.dart';
import '../core/config/estrutura_pedagogica.dart';

// =========================
// GAME STATE
// =========================
///
/// Responsável por:
/// ✅ Controle de fases
/// ✅ Controle de perguntas
/// ✅ Controle de pontuação
/// ✅ Controle de níveis
/// ✅ Estrutura pedagógica
///
class GameState {
  // =========================
  // FASE ATUAL
  // =========================
  ///
  /// Cada nível possui:
  /// Fase 1 -> 10
  ///
  int fase = 1;

  // =========================
  // PERGUNTA ATUAL
  // =========================
  int perguntaAtual = 0;

  // =========================
  // PONTUAÇÃO
  // =========================
  int pontos = 0;

  int acertos = 0;

  // =========================
  // NÍVEL DO JOGADOR
  // =========================
  Nivel nivel = Nivel.bronze;

  // =========================
  // PONTOS DA FASE
  // =========================
  ///
  /// Usado para remover pontos
  /// quando errar.
  ///
  int pontosFase = 0;

  // =========================
  // ANO ESCOLAR
  // =========================
  AnoEscolar get anoEscolarAtual {
    return nivelParaAnoEscolar[nivel]!;
  }

  // =========================
  // CONTEÚDO PEDAGÓGICO
  // =========================
  List<String> get conteudoAtual {
    return conteudoPorAno[anoEscolarAtual]!;
  }

  // =========================
  // ESTRUTURA
  // =========================
  int get fasesPorNivel {
    return EstruturaProgresso.fasesPorNivel;
  }

  int get perguntasPorFase {
    return EstruturaProgresso.perguntasPorFase;
  }

  int get perguntasPorNivel {
    return EstruturaProgresso.perguntasPorNivel;
  }

  int get perguntasTotal {
    return EstruturaProgresso.perguntasTotal;
  }

  // =========================
  // RESET FASE
  // =========================
  ///
  /// Reinicia apenas:
  /// ✅ perguntas
  /// ✅ acertos da fase
  /// ✅ pontos da fase
  ///
  /// NÃO reinicia:
  /// ❌ nível
  /// ❌ fase
  /// ❌ pontos totais
  ///
  void resetFase() {
    perguntaAtual = 0;

    acertos = 0;

    pontosFase = 0;
  }

  // =========================
  // RESET PERGUNTAS
  // =========================
  ///
  /// Usado ao avançar de fase
  ///
  void resetPerguntas() {
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
    if (perguntaAtual < perguntasPorFase) {
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
  ///
  /// Completa ao atingir:
  /// 10 perguntas
  ///
  bool faseCompleta() {
    return perguntaAtual >= perguntasPorFase;
  }

  // =========================
  // SUBIR NÍVEL
  // =========================
  ///
  /// Bronze -> Prata
  /// Prata -> Ouro
  /// Ouro -> Platina
  /// Platina -> Mestre
  ///
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

  // =========================
  // NOME DO NÍVEL
  // =========================
  String get nomeNivel {
    switch (nivel) {
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
  String get proximoNivelNome {
    switch (nivel) {
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
  // COMPLETOU NÍVEL
  // =========================
  ///
  /// Fase 10 concluída
  ///
  bool completouNivel() {
    return fase >= fasesPorNivel;
  }

  // =========================
  // AVANÇAR FASE
  // =========================
  ///
  /// Bronze fase 1 -> 10
  /// depois sobe para Prata
  ///
  void avancarFase() {
    // =========================
    // AINDA TEM FASE
    // =========================
    if (fase < fasesPorNivel) {
      fase++;

      resetPerguntas();

      return;
    }

    // =========================
    // COMPLETOU O NÍVEL
    // =========================
    subirNivel();

    fase = 1;

    resetPerguntas();
  }
}