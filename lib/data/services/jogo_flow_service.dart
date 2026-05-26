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

  Pergunta? perguntaAtual;
  Timer? timer;
  bool jogoAtivo = false;
  int tempoRestante = 60; // Inicia em 60 para disputa
  int tempoTreino = 0;    // Inicia em 0 para treino
  String ultimaPergunta = "";

  JogoFlowService({
    required this.context,
    required this.perfil,
    required this.disputaAtiva,
    required this.perguntaService,
    required this.respostaController,
    required this.atualizarTela,
  });

  int get displayTempo => disputaAtiva ? tempoRestante : tempoTreino;

  void iniciarDesafio({required VoidCallback onTempoEsgotado}) {
    if (jogoAtivo) return;

    final gameState = context.read<GameState>();
    if (gameState.fase == 1 && disputaAtiva) {
      gameState.resetTempoAcumulado();
    }

    gameState.resetFase();
    jogoAtivo = true;
    
    // Inicialização baseada no modo
    tempoRestante = disputaAtiva ? 60 : 0;
    tempoTreino = 0;

    ultimaPergunta = "";
    gerarPergunta();
    iniciarCronometro(onTempoEsgotado: onTempoEsgotado);
    atualizarTela();
  }

  void iniciarCronometro({required VoidCallback onTempoEsgotado}) {
    cancelarTimer();

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!jogoAtivo) return;

      if (disputaAtiva) {
        if (tempoRestante <= 0) {
          finalizarJogo(onTempoEsgotado);
          return;
        }
        tempoRestante--;
      } else {
        tempoTreino++;
      }
      // Sempre incrementa no estado para persistência
      context.read<GameState>().incrementarTempoGeral();
      atualizarTela();
    });
  }

  void continuarPartida() {
    if (jogoAtivo) return;
    
    final gameState = context.read<GameState>();
    
    // Recupera o tempo já acumulado do estado salvo
    int tempoSalvo = gameState.tempoAcumuladoNivel;
    
    if (disputaAtiva) {
      tempoRestante = (60 - tempoSalvo).clamp(0, 60);
    } else {
      tempoTreino = tempoSalvo;
    }

    jogoAtivo = true;
    if (perguntaAtual == null) gerarPergunta();
    iniciarCronometro(onTempoEsgotado: () => debugPrint("Tempo esgotado!"));
    atualizarTela();
  }

  void processarAcerto({required VoidCallback onConcluirFase}) {
    final gameState = context.read<GameState>();
    gameState.registrarAcerto(
      tempoRestante: disputaAtiva ? tempoRestante : tempoTreino, 
      ehModoDisputa: disputaAtiva
    );
    HapticFeedback.mediumImpact();

    if (gameState.indicePerguntaAtual >= gameState.maxPerguntasPorFase) {
      // Fase concluída, mas o jogo continua ativo para o cronômetro não resetar
      onConcluirFase();
    } else {
      gameState.avancarPergunta();
      gerarPergunta();
      atualizarTela();
    }
  }

  // --- MÉTODOS AUXILIARES ---
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

  void validarResposta({required VoidCallback onAcerto, required Function(String correta) onErro}) {
    if (!jogoAtivo || perguntaAtual == null) return;
    final digitado = respostaController.text.trim().toLowerCase();
    final correta = perguntaAtual!.resposta.trim().toLowerCase();
    if (digitado.isEmpty) return;
    digitado == correta ? onAcerto() : onErro(correta);
  }

  void finalizarJogo(VoidCallback onTempoEsgotado) {
    cancelarTimer();
    jogoAtivo = false;
    atualizarTela();
    onTempoEsgotado();
  }

  void pausarJogo() {
    jogoAtivo = false;
    cancelarTimer();
    atualizarTela();
  }
  
  void retomarJogo() {
    if (jogoAtivo) return;
    jogoAtivo = true;
    iniciarCronometro(onTempoEsgotado: () => debugPrint("Tempo esgotado!"));
    atualizarTela();
  }

  void cancelarTimer() {
    timer?.cancel();
    timer = null;
  }

  void dispose() => cancelarTimer();
}