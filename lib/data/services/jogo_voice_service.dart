import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_state.dart';
// Ajuste o caminho abaixo conforme a localização real do seu Controller
import '../../presentation/controllers/jogo_controller.dart';

class JogoVoiceService {
  final BuildContext context;

  JogoVoiceService({
    required this.context,
  });

  // =========================
  // LER PERGUNTA
  // =========================
  Future<void> iniciarLeituraPergunta({
    required String pergunta,
    required bool jogoAtivo,
    required VoidCallback onAcionarMicrofone,
  }) async {
    final controller = context.read<JogoController>();

    // Garante que o microfone pare antes
    controller.pararMicrofone();

    await controller.falar(pergunta);

    // Web não suporta bem speech_to_text
    if (!kIsWeb &&
        jogoAtivo &&
        context.read<GameState>().acessibilidadeVoz) {
      Future.delayed(
        const Duration(milliseconds: 1200),
        onAcionarMicrofone,
      );
    }
  }

  // =========================
  // MICROFONE
  // =========================
  void acionarMicrofone({
    required bool jogoAtivo,
    required Function(String texto) onTextoCapturado,
    required VoidCallback onFinalizado,
  }) {
    if (!jogoAtivo) return;

    final gameState = context.read<GameState>();

    context.read<JogoController>().alternarMicrofone(
      onTextoCapturado: (textoReconhecido) {
        final textoNormalizado = gameState.normalizarRespostaFalada(
          textoReconhecido,
        );

        onTextoCapturado(textoNormalizado);
      },
      onFinalizado: onFinalizado,
    );
  }

  // =========================
  // FALAR FEEDBACK
  // =========================
  Future<void> falarFeedback(String texto) async {
    await context
        .read<JogoController>()
        .falarFeedbackSistema(texto);
  }

  // =========================
  // PARAR TUDO
  // =========================
  void pararTudo() {
    final controller = context.read<JogoController>();
    controller.pararMicrofone();
    controller.pararTTS();
  }

  // =========================
  // ATIVAR/DESATIVAR ACESSIBILIDADE
  // =========================
  void alternarAcessibilidade({
    required bool jogoAtivo,
    required String? perguntaAtual,
    required VoidCallback onRelerPergunta,
  }) {
    final gameState = context.read<GameState>();

    gameState.alternarAcessibilidadeVoz();

    // Ativou
    if (gameState.acessibilidadeVoz) {
      context.read<JogoController>().resetarTrava();

      if (jogoAtivo && perguntaAtual != null) {
        onRelerPergunta();
      }
    }
    // Desativou
    else {
      pararTudo();
    }
  }

  // =========================
  // STATUS MICROFONE
  // =========================
  bool get estaOuvindo {
    return context.watch<JogoController>().estaOuvindoMicrofone;
  }
}