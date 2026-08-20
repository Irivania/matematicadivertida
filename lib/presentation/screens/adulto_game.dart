// lib/presentation/screens/adulto_game.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/game_state.dart';

class AdultoGame extends StatelessWidget {
  const AdultoGame({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<GameState>();
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. FUNDO ROXO MÁGICO COM ELEMENTOS FLUTUANTES (Padrão unificado do app)
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
                  child: Icon(Icons.calculate_outlined, color: Colors.white.withOpacity(0.06), size: 60),
                )),
              ),
            ),
          ),

          // 2. CONTEÚDO PRINCIPAL
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CABEÇALHO REFINADO EM VIDRO TRANSLÚCIDO
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Desafio Matemático 🧠",
                                style: GoogleFonts.orbitron(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Modo Adulto",
                                style: GoogleFonts.poppins(color: Colors.cyanAccent, fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // CARD DE STATUS / PROGRESSO MODERNO
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Fase Atual: ${state.fase}",
                              style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500, fontSize: 16),
                            ),
                            Text(
                              "Questão ${state.indicePerguntaAtual}",
                              style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: state.indicePerguntaAtual / (state.maxPerguntasPorFase > 0 ? state.maxPerguntasPorFase : 10),
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),

                  // ÁREA DA QUESTÃO ALINHADA AO TOPO COM ELEGÂNCIA
                  Center(
                    child: Column(
                      children: [
                        const Text(
                          "Analise e resolva com atenção",
                          style: TextStyle(color: Colors.white54, fontSize: 14, fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Questão ${state.indicePerguntaAtual}",
                          style: GoogleFonts.orbitron(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}