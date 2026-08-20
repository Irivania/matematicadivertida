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

  int tempoRestante = 0; 
  int tempoTreino = 0;    
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
    
    if (gameState.fase == 1) {
      gameState.resetTempoAcumulado();
    }

    gameState.resetFase();
    jogoAtivo = true;
    
    tempoRestante = 0;
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
        tempoRestante++;
      } else {
        tempoTreino++;
      }

      context.read<GameState>().incrementarTempoGeral();
      atualizarTela();
    });
  }

  void continuarPartida() {
    if (jogoAtivo) return;
    
    final gameState = context.read<GameState>();
    int tempoSalvo = gameState.tempoAcumuladoNivel;
    
    if (disputaAtiva) {
      tempoRestante = tempoSalvo;
    } else {
      tempoTreino = tempoSalvo;
    }

    jogoAtivo = true;
    if (perguntaAtual == null) gerarPergunta();
    iniciarCronometro(onTempoEsgotado: () => debugPrint("Fim de tempo não aplicável"));
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
      onConcluirFase();
    } else {
      gameState.avancarPergunta();
      gerarPergunta();
      atualizarTela();
    }
  }

  // --- MÉTODOS DE CONTROLE DE TEMPO ---
  
  void pausarDefinitivo() {
    jogoAtivo = false;
    cancelarTimer();
    atualizarTela();
  }

  void pausarJogo() {
    jogoAtivo = false;
    cancelarTimer();
    atualizarTela();
  }
  
  void retomarJogo() {
    if (jogoAtivo) return;
    jogoAtivo = true;
    iniciarCronometro(onTempoEsgotado: () => debugPrint("Retomando..."));
    atualizarTela();
  }

  void cancelarTimer() {
    timer?.cancel();
    timer = null;
  }

  // --- AUXILIARES ---
  void gerarPergunta() {
    try {
      final gameState = context.read<GameState>();
      
      // Captura o idioma atual selecionado ('pt' ou 'en')
      String idiomaAtual = gameState.currentLocale.languageCode;

      final pergunta = perguntaService.gerar(
        perfil: perfil,
        nivel: gameState.nivelParaService,
        fase: gameState.fase,
        languageCode: idiomaAtual, // <--- Envia o idioma para o PerguntaService
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
  }

  void dispose() => cancelarTimer();
}