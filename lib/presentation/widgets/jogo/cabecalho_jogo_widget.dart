// lib/presentation/widgets/jogo/cabecalho_jogo_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:matematicadivertida/l10n/app_localizations.dart';
import '../../../data/models/game_state.dart';
import 'hud_widget.dart';

class CabecalhoJogoWidget extends StatelessWidget {
  final GameState gs;
  final bool disputaAtiva;
  final int tempoRestante;

  const CabecalhoJogoWidget({
    super.key,
    required this.gs,
    required this.disputaAtiva,
    required this.tempoRestante,
  });

  @override
  Widget build(BuildContext context) {
    // Escuta o idioma para atualizar dinamicamente
    final gameState = context.watch<GameState>();
    AppLocalizations.of(context)!; 

    final bool eIngles = gameState.currentLocale.languageCode == 'en';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
              const SizedBox(width: 8),
              Text(gs.nomeNivelExibicao, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          HUDWidget(state: gs, isDisputa: disputaAtiva, tempoRestante: tempoRestante),
          const Divider(color: Colors.white24, height: 20),
          Text(
            eIngles 
              ? "Question ${gs.indicePerguntaAtual} of ${gs.maxPerguntasPorFase}"
              : "Pergunta ${gs.indicePerguntaAtual} de ${gs.maxPerguntasPorFase}", 
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}