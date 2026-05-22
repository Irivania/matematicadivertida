// lib/presentation/widgets/dialogs/fase_concluida_dialog.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class FaseConcluidaDialog extends StatelessWidget {
  final String titulo;
  final int acertos;
  final bool disputaAtiva;
  final bool nivelConcluido;
  final int tempoAtualSegundos;
  final int recordeHistoricoSegundos;
  final bool foiRecorde;
  final VoidCallback onRecomecar;
  final VoidCallback onAvancar;
  final String textoBotaoAvancar;

  const FaseConcluidaDialog({
    super.key,
    required this.titulo,
    required this.acertos,
    required this.disputaAtiva,
    required this.nivelConcluido,
    required this.tempoAtualSegundos,
    required this.recordeHistoricoSegundos,
    required this.foiRecorde,
    required this.onRecomecar,
    required this.onAvancar,
    required this.textoBotaoAvancar,
  });

  // Função utilitária interna para formatar o tempo de forma limpa
  String _formatarMinutos(int segundosTotais) {
    if (segundosTotais <= 0) return "0m 00s";
    int minutos = segundosTotais ~/ 60;
    int segundosRestantes = segundosTotais % 60;
    return "${minutos}m ${segundosRestantes.toString().padLeft(2, '0')}s";
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.backgroundEscuro,
      title: Text(
        titulo, 
        style: const TextStyle(color: AppColors.neonCiano, fontWeight: FontWeight.bold)
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Você acertou $acertos questões!", style: const TextStyle(color: Colors.white)),
          if (disputaAtiva) ...[
            const SizedBox(height: 16),
            if (nivelConcluido) ...[
              const Text(
                "🎉 PARABÉNS! NÍVEL COMPLETO!", 
                style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 16)
              ),
              const SizedBox(height: 10),
              Text(
                "Tempo Final: ${_formatarMinutos(tempoAtualSegundos)}", 
                style: const TextStyle(color: Colors.white, fontSize: 15)
              ),
              Text(
                "Seu Recorde: ${_formatarMinutos(recordeHistoricoSegundos)}", 
                style: const TextStyle(color: Colors.amber, fontSize: 15)
              ),
              if (foiRecorde) ...[
                const SizedBox(height: 12),
                const Text(
                  "✨ NOVO RECORDE GLOBAL! ✨", 
                  style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14)
                ),
              ]
            ] else ...[
              // Se for apenas uma mudança de fase comum no modo disputa
              Text(
                "Tempo acumulado: ${_formatarMinutos(tempoAtualSegundos)}", 
                style: const TextStyle(color: Colors.purpleAccent)
              ),
            ]
          ]
        ],
      ),
      actions: [
        TextButton(
          onPressed: onRecomecar,
          child: Text(
            nivelConcluido ? "REPETIR NÍVEL" : "RECOMEÇAR DO ZERO", 
            style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)
          ),
        ),
        ElevatedButton(
          onPressed: onAvancar,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.neonCiano),
          child: Text(
            textoBotaoAvancar, 
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
          ),
        ),
      ],
    );
  }
}