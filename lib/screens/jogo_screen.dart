import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/pergunta_service.dart';
import '../models/pergunta.dart';
import '../controllers/game_controller.dart';
import '../widgets/game_hud.dart';

class JogoScreen extends StatefulWidget {
  const JogoScreen({super.key});

  @override
  State<JogoScreen> createState() => _JogoScreenState();
}

class _JogoScreenState extends State<JogoScreen> {
  final service = PerguntaService();
  final controller = GameController();

  Pergunta? perguntaAtual;

  final respostaController = TextEditingController();

  Timer? timer;
  int tempoRestante = 60;

  bool jogoAtivo = false;
  String mensagem = "Clique em INICIAR ou pressione ENTER";

  @override
  void dispose() {
    timer?.cancel();
    respostaController.dispose();
    super.dispose();
  }

  // =========================
  // INICIAR
  // =========================
  void iniciar() {
    setState(() {
      mensagem = "";
      jogoAtivo = true;
      tempoRestante = 60;
    });

    controller.state.resetFase();

    gerarPergunta();
    iniciarTimer();
  }

  void iniciarTimer() {
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!jogoAtivo) return;

      if (tempoRestante <= 0) {
        t.cancel();
        tempoEsgotado();
      } else {
        setState(() {
          tempoRestante--;
        });
      }
    });
  }

  // =========================
  // PARAR
  // =========================
  void pararJogo(String msg) {
    timer?.cancel();

    setState(() {
      jogoAtivo = false;
      mensagem = msg;
    });
  }

  // =========================
  // GERAR PERGUNTA
  // =========================
  void gerarPergunta() {
    final p = service.gerarSimples();

    setState(() {
      perguntaAtual = p;
      respostaController.clear();
    });
  }

  // =========================
  // RESPONDER
  // =========================
  void responder() {
    if (!jogoAtivo || perguntaAtual == null) return;

    final resp = respostaController.text.trim();
    if (resp.isEmpty) return;

    final correto = resp == perguntaAtual!.resposta;
    final resultado = controller.responder(correto);

    // ❌ ERRO
    if (!correto) {
      controller.erro();

      pararJogo(
        "❌ Errou!\n"
        "Resposta correta: ${perguntaAtual!.resposta}\n\n"
        "Fase reiniciada",
      );

      perguntaAtual = null;
      tempoRestante = 60;
      return;
    }

    // 🎉 FASE COMPLETA
    if (resultado == ResultadoResposta.faseCompleta) {
      final faseAtual = controller.state.fase;

      pararJogo(
        "🏆 FASE $faseAtual CONCLUÍDA!\n\n"
        "Você mandou muito bem! 💪\n"
        "Prepare-se para a fase ${faseAtual + 1} 🔥\n\n"
        "Pontuação: ${controller.state.pontos}",
      );

      controller.proximaFase();

      perguntaAtual = null;
      tempoRestante = 60;
      return;
    }

    // continua
    gerarPergunta();
  }

  // =========================
  // TEMPO ESGOTADO
  // =========================
  void tempoEsgotado() {
    controller.erro();

    pararJogo(
      "⏰ Tempo esgotado!\nFase reiniciada",
    );

    perguntaAtual = null;
    tempoRestante = 60;
  }

  // =========================
  // ENTER GLOBAL
  // =========================
  void onEnter() {
    if (!jogoAtivo) {
      iniciar();
    } else {
      responder();
    }
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    final state = controller.state;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Matemática Divertida"),
      ),
      body: FocusScope(
        autofocus: true,
        child: Shortcuts(
          shortcuts: {
            LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
          },
          child: Actions(
            actions: {
              ActivateIntent: CallbackAction<ActivateIntent>(
                onInvoke: (intent) {
                  onEnter();
                  return null;
                },
              ),
            },
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  GameHud(state: state),

                  const SizedBox(height: 10),

                  Text(
                    "⏱️ $tempoRestante s",
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.red,
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (mensagem.isNotEmpty)
                    Text(
                      mensagem,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),

                  const SizedBox(height: 20),

                  if (jogoAtivo && perguntaAtual != null)
                    Column(
                      children: [
                        Text(
                          perguntaAtual!.pergunta,
                          style: const TextStyle(fontSize: 22),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: respostaController,
                          keyboardType: TextInputType.number,
                          onSubmitted: (_) => responder(),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Digite sua resposta",
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: onEnter,
                    child: Text(jogoAtivo ? "Confirmar" : "Iniciar"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}