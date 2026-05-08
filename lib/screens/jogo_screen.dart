import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/pergunta_service.dart';
import '../models/pergunta.dart';
import '../controllers/game_controller.dart';

class JogoScreen extends StatefulWidget {
  const JogoScreen({super.key});

  @override
  State<JogoScreen> createState() => _JogoScreenState();
}

class _JogoScreenState extends State<JogoScreen>
    with SingleTickerProviderStateMixin {
  final service = PerguntaService();
  final controller = GameController();

  Pergunta? perguntaAtual;

  final respostaController = TextEditingController();
  final FocusNode respostaFocusNode = FocusNode();

  Timer? timer;

  int tempoRestante = 60;

  bool jogoAtivo = false;
  bool mostrarVitoria = false;

  // 🔥 CONTROLA SE ESTÁ AGUARDANDO PRÓXIMA FASE
  bool aguardandoProximaFase = false;

  String mensagem = 'Pressione ENTER para iniciar';

  late AnimationController _animController;

  // =========================
  // INIT
  // =========================
  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        respostaFocusNode.requestFocus();
      }
    });
  }

  // =========================
  // DISPOSE
  // =========================
  @override
  void dispose() {
    timer?.cancel();

    respostaController.dispose();
    respostaFocusNode.dispose();

    _animController.dispose();

    super.dispose();
  }

  // =========================
  // NOME DO NÍVEL
  // =========================
  String getNivelNome() {
    final fase = controller.state.fase;

    if (fase <= 10) return '🥉 Bronze';
    if (fase <= 20) return '🥈 Prata';
    if (fase <= 30) return '🥇 Ouro';
    if (fase <= 40) return '💎 Platina';

    return '👑 Mestre';
  }

  // =========================
  // PRÓXIMO NÍVEL
  // =========================
  String getProximoNivelNome(int faseAtual) {
    if (faseAtual == 10) return '🥈 Prata';
    if (faseAtual == 20) return '🥇 Ouro';
    if (faseAtual == 30) return '💎 Platina';
    if (faseAtual == 40) return '👑 Mestre';

    return getNivelNome();
  }

  // =========================
  // MENSAGEM DE NÍVEL
  // =========================
  String getMensagemNivel(int faseAtual) {
    if (faseAtual == 10 ||
        faseAtual == 20 ||
        faseAtual == 30 ||
        faseAtual == 40) {
      return '\n\n🎉 PARABÉNS!\n'
          'Você avançou para o nível ${getProximoNivelNome(faseAtual)}';
    }

    return '';
  }

  // =========================
  // INICIAR
  // =========================
  void iniciar() {
    setState(() {
      jogoAtivo = true;

      aguardandoProximaFase = false;

      mensagem = '';

      tempoRestante = 60;
    });

    controller.state.resetFase();

    gerarPergunta();

    iniciarTimer();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        respostaFocusNode.requestFocus();
      }
    });
  }

  // =========================
  // CONTINUAR FASE
  // =========================
  void continuarProximaFase() {
    setState(() {
      jogoAtivo = true;

      aguardandoProximaFase = false;

      mensagem = '';

      tempoRestante = 60;
    });

    gerarPergunta();

    iniciarTimer();

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        respostaFocusNode.requestFocus();
      }
    });
  }

  // =========================
  // TIMER
  // =========================
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
  // PARAR JOGO
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

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        respostaFocusNode.requestFocus();
      }
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

    // =========================
    // ERRO
    // =========================
    if (!correto) {
      controller.erro();

      pararJogo(
        '❌ Resposta incorreta!\n\n'
        'Resposta correta: ${perguntaAtual!.resposta}\n\n'
        'Pressione ENTER para tentar novamente',
      );

      perguntaAtual = null;

      tempoRestante = 60;

      return;
    }

    // =========================
    // FASE COMPLETA
    // =========================
    if (resultado == ResultadoResposta.faseCompleta) {
      final faseAtual = controller.state.fase;

      setState(() {
        mostrarVitoria = true;

        aguardandoProximaFase = true;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            mostrarVitoria = false;
          });
        }
      });

      final mensagemNivel = getMensagemNivel(faseAtual);

      // 🔥 AVANÇA A FASE
      controller.proximaFase();

      pararJogo(
        '🏆 FASE $faseAtual CONCLUÍDA!\n\n'
        'Você estava no nível ${getNivelNome()}'
        '$mensagemNivel\n\n'
        '🚀 Pressione ENTER para continuar',
      );

      perguntaAtual = null;

      tempoRestante = 60;

      return;
    }

    gerarPergunta();
  }

  // =========================
  // TEMPO ESGOTADO
  // =========================
  void tempoEsgotado() {
    controller.erro();

    pararJogo(
      '⏰ Tempo esgotado!\n\n'
      'Pressione ENTER para reiniciar',
    );

    perguntaAtual = null;

    tempoRestante = 60;
  }

  // =========================
  // ENTER / SPACE
  // =========================
  void onAction() {
    // 🔥 CONTINUAR PRÓXIMA FASE
    if (aguardandoProximaFase) {
      continuarProximaFase();

      return;
    }

    // 🔥 INICIAR NOVO JOGO
    if (!jogoAtivo) {
      iniciar();

      return;
    }

    // 🔥 RESPONDER
    responder();
  }

  // =========================
  // COR TIMER
  // =========================
  Color getCorTimer() {
    if (tempoRestante > 30) {
      return Colors.greenAccent;
    }

    if (tempoRestante > 10) {
      return Colors.orangeAccent;
    }

    return Colors.redAccent;
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    final state = controller.state;

    return Scaffold(
      body: Focus(
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.enter) {
              onAction();

              return KeyEventResult.handled;
            }

            final isInputFocused = respostaFocusNode.hasFocus;

            if (event.logicalKey == LogicalKeyboardKey.space &&
                !isInputFocused) {
              onAction();

              return KeyEventResult.handled;
            }
          }

          return KeyEventResult.ignored;
        },
        child: Stack(
          children: [
            // =========================
            // FUNDO
            // =========================
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF1E293B),
                    Color(0xFF334155),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // =========================
            // BOLHAS
            // =========================
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Positioned(
              bottom: -80,
              left: -50,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // =========================
                      // TOPO
                      // =========================
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              '🎮 Matemática Divertida',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),

                      const SizedBox(height: 25),

                      // =========================
                      // HUD
                      // =========================
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFFA726),
                              Color(0xFFFF7043),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              getNivelNome(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              '🏆 FASE ${state.fase}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 20),

                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                              children: [
                                _infoCard(
                                  '📘',
                                  'Pergunta',
                                  '${state.perguntaAtual}/10',
                                ),
                                _infoCard(
                                  '✅',
                                  'Acertos',
                                  '${state.acertos}',
                                ),
                                _infoCard(
                                  '🎯',
                                  'Pontos',
                                  '${state.pontos}',
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(30),
                              child: LinearProgressIndicator(
                                minHeight: 18,
                                value: state.perguntaAtual / 10,
                                backgroundColor: Colors.white24,
                                valueColor:
                                    const AlwaysStoppedAnimation(
                                  Colors.yellow,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // =========================
                      // TIMER
                      // =========================
                      AnimatedContainer(
                        duration:
                            const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: getCorTimer().withOpacity(0.2),
                          borderRadius:
                              BorderRadius.circular(30),
                          border: Border.all(
                            color: getCorTimer(),
                            width: 2,
                          ),
                        ),
                        child: Text(
                          '⏱️ $tempoRestante s',
                          style: TextStyle(
                            color: getCorTimer(),
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // =========================
                      // PERGUNTA
                      // =========================
                      if (jogoAtivo &&
                          perguntaAtual != null)
                        ScaleTransition(
                          scale: Tween<double>(
                            begin: 0.98,
                            end: 1.02,
                          ).animate(_animController),
                          child: Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.all(30),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withOpacity(0.15),
                                  blurRadius: 20,
                                  offset:
                                      const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  '🧠 DESAFIO',
                                  style: TextStyle(
                                    color: Colors.orange,
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),

                                const SizedBox(height: 20),

                                Text(
                                  perguntaAtual!.pergunta,
                                  textAlign:
                                      TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 42,
                                    fontWeight:
                                        FontWeight.bold,
                                    color:
                                        Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 35),

                      // =========================
                      // INPUT
                      // =========================
                      if (jogoAtivo)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.1),
                                blurRadius: 15,
                                offset:
                                    const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller:
                                respostaController,
                            focusNode:
                                respostaFocusNode,
                            autofocus: true,
                            keyboardType:
                                TextInputType.number,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                            onSubmitted: (_) =>
                                responder(),
                            decoration: InputDecoration(
                              hintText:
                                  'Digite sua resposta',
                              hintStyle: TextStyle(
                                color:
                                    Colors.grey.shade500,
                              ),
                              border:
                                  OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  25,
                                ),
                                borderSide:
                                    BorderSide.none,
                              ),
                              contentPadding:
                                  const EdgeInsets.symmetric(
                                vertical: 28,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 35),

                      // =========================
                      // MENSAGEM
                      // =========================
                      if (mensagem.isNotEmpty)
                        Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white
                                .withOpacity(0.15),
                            borderRadius:
                                BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.white24,
                            ),
                          ),
                          child: Text(
                            mensagem,
                            textAlign:
                                TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),

                      const SizedBox(height: 35),

                      // =========================
                      // BOTÃO
                      // =========================
                      SizedBox(
                        width: 260,
                        height: 70,
                        child: ElevatedButton(
                          onPressed: onAction,
                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.orange,
                            foregroundColor:
                                Colors.white,
                            elevation: 12,
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                30,
                              ),
                            ),
                          ),
                          child: Text(
                            jogoAtivo
                                ? 'CONFIRMAR'
                                : aguardandoProximaFase
                                    ? 'PRÓXIMA FASE'
                                    : 'INICIAR JOGO',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        '⌨️ ENTER ou SPACE para jogar',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),

            // =========================
            // VITÓRIA
            // =========================
            if (mostrarVitoria)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: Text(
                      '🎉 PARABÉNS! 🎉',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.yellow,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // =========================
  // INFO CARD
  // =========================
  Widget _infoCard(
    String emoji,
    String titulo,
    String valor,
  ) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 28),
        ),

        const SizedBox(height: 8),

        Text(
          titulo,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          valor,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}