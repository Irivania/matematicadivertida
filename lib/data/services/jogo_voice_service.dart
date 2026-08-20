// lib/data/services/jogo_voice_service.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../models/game_state.dart';
import '../../presentation/controllers/jogo_controller.dart';

class JogoVoiceService {
  JogoVoiceService();

  // =========================
  // LER PERGUNTA (Com suporte a idioma)
  // =========================
  Future<void> iniciarLeituraPergunta({
    required JogoController jogoController,
    required GameState gameState,
    required String pergunta,
    required bool jogoAtivo,
    required VoidCallback onAcionarMicrofone,
    String? idioma,
  }) async {
    jogoController.pararMicrofone();

    // Descobre se o idioma atual é inglês
    final bool eIngles = gameState.currentLocale.languageCode == 'en';

    // Prepara e lê a pergunta passando o parâmetro de idioma para o JogoController
    jogoController.prepararProximaPergunta(pergunta, eIngles: eIngles);

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

    final bool eIngles = gameState.currentLocale.languageCode == 'en';

    jogoController.alternarMicrofone(
      eIngles: eIngles,
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
  Future<void> falarFeedback(JogoController jogoController, GameState gameState, String texto) async {
    final bool eIngles = gameState.currentLocale.languageCode == 'en';
    await jogoController.falarFeedbackSistema(texto, eIngles: eIngles);
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

    if (gameState.acessibilidadeVoz) {
      jogoController.resetarTrava();

      if (jogoAtivo && perguntaAtual != null) {
        onRelerPergunta();
      }
    } else {
      pararTudo(jogoController);
    }
  }
}