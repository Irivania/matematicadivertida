// lib/presentation/widgets/jogo/area_pergunta.dart

import 'package:flutter/material.dart';
import '../../../data/models/pergunta.dart';
import '../../../core/theme/app_colors.dart';

class AreaPerguntaWidget extends StatelessWidget {
  final Pergunta? perguntaAtual;
  final bool jogoAtivo;
  final bool disputaAtiva;
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onValidar;

  const AreaPerguntaWidget({
    super.key,
    required this.perguntaAtual,
    required this.jogoAtivo,
    required this.disputaAtiva,
    required this.controller,
    required this.focusNode,
    required this.onValidar,
  });

  @override
  Widget build(BuildContext context) {
    if (!jogoAtivo) {
      return _buildModoInfo();
    }

    return Column(
      children: [
        if (disputaAtiva) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "VELOCIDADE MÁXIMA",
              style: TextStyle(color: Colors.purpleAccent, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
        ],
        Text(
          perguntaAtual?.pergunta ?? "",
          style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 180,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            textAlign: TextAlign.center,
            autofocus: false, // CORREÇÃO: Deixamos false para o Chrome não bugar o ciclo de renderização
            keyboardType: TextInputType.number,
            style: TextStyle(
              color: disputaAtiva ? Colors.purpleAccent : AppColors.neonCiano,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
            decoration: const InputDecoration(
              hintText: "?",
              hintStyle: TextStyle(color: Colors.white24),
            ),
            onSubmitted: (_) => onValidar(),
          ),
        ),
      ],
    );
  }

  Widget _buildModoInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 30),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: disputaAtiva ? Colors.purpleAccent : AppColors.neonCiano, width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            disputaAtiva ? "🏁 MODO DISPUTA" : "🧠 MODO TREINO",
            style: TextStyle(color: disputaAtiva ? Colors.purpleAccent : AppColors.neonCiano, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            disputaAtiva ? "Responda o mais rápido possível!\nErrar encerra o desafio." : "Treine suas habilidades matemáticas.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }
}