// lib/presentation/widgets/jogo/area_pergunta.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/pergunta.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/game_state.dart';

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

    // Escuta o idioma para alternar dinamicamente
    final gs = context.watch<GameState>();
    final bool eIngles = gs.currentLocale.languageCode == 'en';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // PERGUNTA MAIS ACIMA E COM FONTE COMPACTA
        Text(
          perguntaAtual?.pergunta ?? "",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26, // Reduzido para subir e otimizar o espaço
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black45, blurRadius: 6)],
          ),
        ),
        const SizedBox(height: 10), // Espaçamento reduzido ao máximo

        // Campo de resposta com foco automático
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: true,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => onValidar(),
            style: TextStyle(
              color: disputaAtiva ? Colors.purpleAccent : AppColors.neonCiano,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: eIngles ? 'Your answer' : 'Sua resposta',
              hintStyle: const TextStyle(color: Colors.white30, fontSize: 18),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10), // Espaçamento reduzido ao máximo

        // Botão de validação traduzido
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onValidar,
              style: ElevatedButton.styleFrom(
                backgroundColor: disputaAtiva ? Colors.purpleAccent : AppColors.neonCiano,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
              ),
              child: Text(
                disputaAtiva 
                  ? (eIngles ? 'SUBMIT ANSWER' : 'ENVIAR RESPOSTA') 
                  : (eIngles ? 'CHECK LEARNING' : 'VERIFICAR APRENDIZADO'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ),
        ),
      ],
    );
  }
}