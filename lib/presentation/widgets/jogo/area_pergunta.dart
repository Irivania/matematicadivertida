// lib/presentation/widgets/jogo/area_pergunta.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          style: const TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
          ),
        ),
        const SizedBox(height: 30),

        // Campo de resposta com foco automático
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: true, // <--- GARANTE QUE O TECLADO ABRA SOZINHO
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => onValidar(), // Enter envia a resposta
            style: TextStyle(
              color: disputaAtiva ? Colors.purpleAccent : AppColors.neonCiano,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: 'Sua resposta',
              hintStyle: const TextStyle(color: Colors.white30),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: onValidar,
              style: ElevatedButton.styleFrom(
                backgroundColor: disputaAtiva ? Colors.purpleAccent : AppColors.neonCiano,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(
                disputaAtiva ? 'ENVIAR RESPOSTA' : 'VERIFICAR APRENDIZADO',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ),
        ),
      ],
    );
  }
}