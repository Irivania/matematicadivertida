// lib/presentation/widgets/home/mission_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:matematicadivertida/l10n/app_localizations.dart';
import '../../../data/models/game_state.dart';
import '../../../core/theme/app_colors.dart';

class MissionCard extends StatelessWidget {
  const MissionCard({super.key});

  @override
  Widget build(BuildContext context) {
    final gs = context.watch<GameState>();
    final t = AppLocalizations.of(context)!;
    
    double progresso = (gs.progressoMissaoDiaria / gs.metaMissaoDiaria).clamp(0.0, 1.0);
    bool concluida = gs.progressoMissaoDiaria >= gs.metaMissaoDiaria;

    // Lógica para mudar a cor da barra conforme o progresso avança:
    Color corBarra;
    if (progresso < 0.5) {
      corBarra = Color.lerp(Colors.redAccent, AppColors.neonCiano, progresso * 2)!;
    } else {
      corBarra = Color.lerp(AppColors.neonCiano, Colors.green.shade600, (progresso - 0.5) * 2)!;
    }

    if (concluida) {
      corBarra = Colors.green.shade600;
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: concluida ? Colors.green.shade600 : Colors.white.withOpacity(0.8), 
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  concluida ? Icons.check_circle : Icons.emoji_events, 
                  color: concluida ? Colors.green.shade700 : Colors.amber.shade800,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  concluida ? t.missaoConcluida : t.missaoDiaria,
                  style: TextStyle(
                    color: concluida ? Colors.green.shade900 : Colors.black87, 
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progresso,
              backgroundColor: Colors.grey.shade300,
              color: corBarra,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              concluida 
                ? t.recompensaRecebida
                : t.progressoQuestao(gs.progressoMissaoDiaria.toString(), gs.metaMissaoDiaria.toString()),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: concluida ? Colors.green.shade800 : Colors.black54, 
                fontSize: 11.5,
                fontWeight: concluida ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}