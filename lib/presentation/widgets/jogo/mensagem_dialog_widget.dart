import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MensagemDialogWidget extends StatelessWidget {
  final String titulo;
  final String conteudo;
  final FocusNode focusNode;
  final VoidCallback onContinuar;

  const MensagemDialogWidget({
    super.key,
    required this.titulo,
    required this.conteudo,
    required this.focusNode,
    required this.onContinuar,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black87,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(20)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(titulo, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Text(conteudo, style: const TextStyle(color: Colors.white, fontSize: 18), textAlign: TextAlign.center),
                const SizedBox(height: 30),
                Focus(
                  focusNode: focusNode,
                  onKeyEvent: (node, event) {
                    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
                      onContinuar();
                      return KeyEventResult.handled;
                    }
                    return KeyEventResult.ignored;
                  },
                  child: ElevatedButton(
                    onPressed: onContinuar,
                    child: const Text("CONTINUAR", style: TextStyle(fontSize: 20)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}