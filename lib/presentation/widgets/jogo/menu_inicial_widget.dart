import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MenuInicialWidget extends StatelessWidget {
  final bool temPartidaSalva;
  final FocusNode menuButtonFocusNode;
  final VoidCallback onContinuar;
  final VoidCallback onIniciar;

  const MenuInicialWidget({
    super.key,
    required this.temPartidaSalva,
    required this.menuButtonFocusNode,
    required this.onContinuar,
    required this.onIniciar,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          if (temPartidaSalva) _buildMenuButton("CONTINUAR", Colors.orange, onContinuar),
          const SizedBox(height: 20),
          Focus(
            focusNode: menuButtonFocusNode,
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
                onIniciar();
                return KeyEventResult.handled;
              }
              return KeyEventResult.ignored;
            },
            child: _buildMenuButton(temPartidaSalva ? "NOVO JOGO" : "COMEÇAR", Colors.green, onIniciar),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(String text, Color color, VoidCallback onPressed) => ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Text(text, style: const TextStyle(fontSize: 28, color: Colors.white)),
      );
}