// lib/data/services/jogo_flow_service.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/game_state.dart';
import '../models/pergunta.dart';
import '../services/pergunta_service.dart';

class JogoFlowService {
  final BuildContext context;
  final String perfil;
  final bool disputaAtiva;
  final PerguntaService perguntaService;
  final TextEditingController respostaController;
  final VoidCallback atualizarTela;

  // Estados do Jogo
  Pergunta? perguntaAtual;
  Timer? timer;
  bool jogoAtivo = false;
  int tempoRestante = 60;
  String ultimaPergunta = "";

  JogoFlowService({
    required this.context,
    required this.perfil,
    required this.disputaAtiva,
    required this.perguntaService,
    required this.respostaController,
    required this.atualizarTela,
  });

  // =========================
  // INICIAR / PAUSAR
  // =========================

  void iniciarDesafio({required VoidCallback onTempoEsgotado}) {
    final gameState = context.read<GameState>();

    if (gameState.fase == 1 && disputaAtiva) {
      gameState.resetTempoAcumulado();
    }

    gameState.resetFase();
    jogoAtivo = true;
    tempoRestante = 60;
    ultimaPergunta = "";

    gerarPergunta();
    iniciarCronometro(onTempoEsgotado: onTempoEsgotado);
    atualizarTela();
  }

  void pausarJogo() {
    jogoAtivo = false;
    cancelarTimer();
    atualizarTela();
  }

  // =========================
  // CRONÔMETRO
  // =========================

  void iniciarCronometro({required VoidCallback onTempoEsgotado}) {
    cancelarTimer();

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!jogoAtivo) return;

      if (tempoRestante <= 0) {
        cancelarTimer();
        jogoAtivo = false;
        atualizarTela();
        onTempoEsgotado();
        return;
      }

      tempoRestante--;

      if (disputaAtiva) {
        context.read<GameState>().incrementarTempoGeral();
      }

      atualizarTela();
    });
  }

  void cancelarTimer() {
    timer?.cancel();
    timer = null;
  }

  // =========================
  // LÓGICA DE PERGUNTAS
  // =========================

  void gerarPergunta() {
    try {
      final gameState = context.read<GameState>();
      final pergunta = perguntaService.gerar(
        perfil: perfil,
        nivel: gameState.nivelParaService,
        fase: gameState.fase,
      );

      if (pergunta.pergunta == ultimaPergunta) return;

      perguntaAtual = pergunta;
      ultimaPergunta = pergunta.pergunta;
      respostaController.clear();
      atualizarTela();
    } catch (e) {
      debugPrint("Erro ao gerar pergunta: $e");
    }
  }

  void validarResposta({
    required VoidCallback onAcerto,
    required Function(String correta) onErro,
  }) {
    if (!jogoAtivo || perguntaAtual == null) return;

    final digitado = respostaController.text.trim().toLowerCase();
    final correta = perguntaAtual!.resposta.trim().toLowerCase();

    if (digitado.isEmpty) return;

    if (digitado == correta) {
      onAcerto();
    } else {
      onErro(correta);
    }
  }

  void processarAcerto({required VoidCallback onConcluirFase}) {
    final gameState = context.read<GameState>();

    gameState.registrarAcerto(tempoRestante: tempoRestante);
    HapticFeedback.mediumImpact();

    if (gameState.indicePerguntaAtual >= gameState.maxPerguntasPorFase) {
      cancelarTimer();
      jogoAtivo = false;
      atualizarTela();
      onConcluirFase();
      return;
    }

    gameState.avancarPergunta();
    gerarPergunta();
    atualizarTela();
  }

  void dispose() {
    cancelarTimer();
  }
}