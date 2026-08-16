// lib/data/services/jogo_voice_service.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../models/game_state.dart';
import '../../presentation/controllers/jogo_controller.dart';

class JogoVoiceService {
  JogoVoiceService();

  // =========================
  // LER PERGUNTA
  // =========================
  Future<void> iniciarLeituraPergunta({
    required JogoController jogoController,
    required GameState gameState,
    required String pergunta,
    required bool jogoAtivo,
    required VoidCallback onAcionarMicrofone,
  }) async {
    jogoController.pararMicrofone();

    // Usa a preparação inteligente para evitar duplicar ou travar na 5ª pergunta
    jogoController.prepararProximaPergunta(pergunta);

    if (!kIsWeb && jogoAtivo && gameState.acessibilidadeVoz) {
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
    required JogoController jogoController,
    required GameState gameState,
    required bool jogoAtivo,
    required Function(String texto) onTextoCapturado,
    required VoidCallback onFinalizado,
  }) {
    if (!jogoAtivo) return;

    jogoController.alternarMicrofone(
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
  Future<void> falarFeedback(JogoController jogoController, String texto) async {
    await jogoController.falarFeedbackSistema(texto);
  }

  // =========================
  // PARAR TUDO
  // =========================
  void pararTudo(JogoController jogoController) {
    jogoController.pararMicrofone();
    jogoController.pararTTS();
  }

  // =========================
  // ATIVAR/DESATIVAR ACESSIBILIDADE
  // =========================
  void alternarAcessibilidade({
    required JogoController jogoController,
    required GameState gameState,
    required bool jogoAtivo,
    required String? perguntaAtual,
    required VoidCallback onRelerPergunta,
  }) {
    gameState.alternarAcessibilidadeVoz();

    // Ativou
    if (gameState.acessibilidadeVoz) {
      jogoController.resetarTrava();

      if (jogoAtivo && perguntaAtual != null) {
        onRelerPergunta();
      }
    }
    // Desativou
    else {
      pararTudo(jogoController);
    }
  }
}