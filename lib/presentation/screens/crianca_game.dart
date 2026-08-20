// lib/presentation/screens/crianca_game.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/game_state.dart';

class CriancaGame extends StatelessWidget {
  const CriancaGame({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. FUNDO MÁGICO / INFANTIL (Gradiente Roxo Vibrante)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF8A49C9), Color(0xFF532287), Color(0xFF221133)],
                ),
              ),
              child: Stack(
                children: List.generate(8, (i) => Positioned(
                  left: (i * 50.0) % 300, top: (i * 80.0) % 600,
                  child: Icon(Icons.star, color: Colors.white.withOpacity(0.08), size: 50),
                )),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Consumer<GameState>(
                builder: (context, state, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // CABEÇALHO / TÍTULO
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const Text(
                            "Modo Criança 🎮",
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 48), // Espaço para equilibrar o layout
                        ],
                      ),
                      
                      const SizedBox(height: 30),

                      // CARD DE STATUS / PONTUAÇÃO
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 8))],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.military_tech, color: Colors.amber, size: 32),
                                const SizedBox(width: 8),
                                Text(
                                  "Nível: ${state.nomeNivelExibicao}",
                                  style: const TextStyle(color: Colors.black87, fontSize: 22, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const Divider(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.star_rounded, color: Colors.orangeAccent, size: 28),
                                const SizedBox(width: 6),
                                Text(
                                  "XP Total: ${state.pontos}",
                                  style: const TextStyle(color: Colors.black54, fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      // BOTÃO LÚDICO DE SIMULAÇÃO / JOGABILIDADE
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amberAccent,
                            foregroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            elevation: 6,
                          ),
                          onPressed: () => state.registrarAcerto(tempoRestante: 10),
                          child: const Text(
                            "Simular Acerto ⭐",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}