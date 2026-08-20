// lib/presentation/widgets/jogo/jogo_action_button.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/game_state.dart';

class JogoActionButton extends StatelessWidget {
  final bool jogoAtivo;
  final bool disputaAtiva;
  final bool estaOuvindo;

  final VoidCallback onIniciar;
  final VoidCallback onValidar;
  final VoidCallback onMicrofone;

  const JogoActionButton({
    super.key,
    required this.jogoAtivo,
    required this.disputaAtiva,
    required this.estaOuvindo,
    required this.onIniciar,
    required this.onValidar,
    required this.onMicrofone,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: ElevatedButton(
        onPressed: _obterAcaoBotao(),
        style: ElevatedButton.styleFrom(
          backgroundColor: _obterCorBotao(),
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone de parada aparece apenas quando está ouvindo
            if (estaOuvindo) 
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.stop_circle, color: AppColors.backgroundEscuro),
              ),
            Text(
              _obterTextoBotao(context),
              style: const TextStyle(
                color: AppColors.backgroundEscuro,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================
  // TEXTO COM SUPORTE A IDIOMA
  // =========================

  String _obterTextoBotao(BuildContext context) {
    final gs = context.watch<GameState>();
    final bool eIngles = gs.currentLocale.languageCode == 'en';

    if (estaOuvindo) {
      return eIngles ? "LISTENING..." : "OUVINDO...";
    }

    if (jogoAtivo) {
      return eIngles ? "VERIFY" : "CONFIRMAR"; // ou "SUBMIT"
    }

    return eIngles ? "START NOW" : "COMEÇAR AGORA";
  }

  // =========================
  // COR
  // =========================

  Color _obterCorBotao() {
    if (estaOuvindo) {
      return Colors.redAccent;
    }

    if (disputaAtiva) {
      return Colors.greenAccent;
    }

    return AppColors.neonCiano;
  }

  // =========================
  // AÇÃO
  // =========================

  VoidCallback _obterAcaoBotao() {
    if (estaOuvindo) {
      return onMicrofone;
    }

    if (jogoAtivo) {
      return onValidar;
    }

    return onIniciar;
  }
}