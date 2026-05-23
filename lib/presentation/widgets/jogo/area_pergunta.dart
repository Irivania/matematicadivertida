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
    if (!jogoAtivo) return const SizedBox.shrink();

    return Column(
      children: [
        Text(
          perguntaAtual?.pergunta ?? "",
          style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 200,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onValidar(),
            cursorColor: disputaAtiva ? Colors.purpleAccent : AppColors.neonCiano,
            cursorWidth: 4,
            style: TextStyle(
              color: disputaAtiva ? Colors.purpleAccent : AppColors.neonCiano,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
            decoration: const InputDecoration(
              hintText: "?",
              hintStyle: TextStyle(color: Colors.white24),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}