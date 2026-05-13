import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/game_state.dart';

class CriancaGame extends StatelessWidget {
  const CriancaGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Modo Criança 🎮")),
      body: Consumer<GameState>(
        builder: (context, state, child) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Nível: ${state.nomeNivelExibicao}", style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 20),
                Text("XP Total: ${state.pontos}", style: const TextStyle(fontSize: 20)),
                ElevatedButton(
                  onPressed: () => state.registrarAcerto(tempoRestante: 10),
                  child: const Text("Simular Acerto"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}