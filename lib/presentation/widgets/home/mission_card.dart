// lib/presentation/widgets/home/mission_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/game_state.dart';
import '../../../core/theme/app_colors.dart';

class MissionCard extends StatelessWidget {
  const MissionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    
    // Calcula a porcentagem para a barra
    double progresso = gs.progressoMissaoDiaria / gs.metaMissaoDiaria;
    bool concluida = gs.progressoMissaoDiaria >= gs.metaMissaoDiaria;

    return Container(
      // Brilho e borda se concluída
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: concluida ? Border.all(color: Colors.greenAccent, width: 2) : null,
        boxShadow: concluida ? [BoxShadow(color: Colors.greenAccent.withOpacity(0.2), blurRadius: 10)] : [],
      ),
      child: Card(
        color: Colors.black.withOpacity(0.6),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    concluida ? Icons.check_circle : Icons.emoji_events, 
                    color: concluida ? Colors.greenAccent : Colors.amber
                  ),
                  const SizedBox(width: 8),
                  Text(
                    concluida ? "MISSÃO CONCLUÍDA! 🎉" : "MISSÃO DIÁRIA 🎯",
                    style: TextStyle(
                      color: concluida ? Colors.greenAccent : Colors.white, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progresso.clamp(0.0, 1.0),
                backgroundColor: Colors.white24,
                color: concluida ? Colors.greenAccent : AppColors.neonCiano,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 10),
              Text(
                concluida 
                  ? "Recompensa recebida: +200 XP! Volte amanhã! 📅" 
                  : "${gs.progressoMissaoDiaria}/${gs.metaMissaoDiaria} questões - Complete para ganhar 200 XP",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: concluida ? Colors.greenAccent : Colors.white70, 
                  fontSize: 12,
                  fontWeight: concluida ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}