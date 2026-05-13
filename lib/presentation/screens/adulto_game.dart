import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/game_state.dart';

class AdultoGame extends StatelessWidget {
  const AdultoGame({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    return Scaffold(
      appBar: AppBar(title: const Text("Desafio Matemático 🧠")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Fase Atual: ${state.fase}"),
            LinearProgressIndicator(value: state.indicePerguntaAtual / state.maxPerguntasPorFase),
            const Spacer(),
            Center(child: Text("Questão ${state.indicePerguntaAtual}", style: const TextStyle(fontSize: 32))),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}