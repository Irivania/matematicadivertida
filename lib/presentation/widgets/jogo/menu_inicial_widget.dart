// lib/presentation/widgets/jogo/menu_inicial_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../data/models/game_state.dart';

class MenuInicialWidget extends StatelessWidget {
  final bool temPartidaSalva;
  final FocusNode menuButtonFocusNode;
  final VoidCallback onContinuar;
  final VoidCallback onIniciar;
  final VoidCallback onReiniciar; // <--- Novo parâmetro adicionado

  const MenuInicialWidget({
    super.key,
    required this.temPartidaSalva,
    required this.menuButtonFocusNode,
    required this.onContinuar,
    required this.onIniciar,
    required this.onReiniciar, // <--- Obrigatório agora
  });

  @override
  Widget build(BuildContext context) {
    // Verifica se o idioma atual é inglês
    final gs = context.watch<GameState>();
    final bool eIngles = gs.currentLocale.languageCode == 'en';

    // Garante que o botão "COMEÇAR" pegue o foco automaticamente assim que a tela abre
    if (!menuButtonFocusNode.hasFocus) {
      Future.microtask(() => menuButtonFocusNode.requestFocus());
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (temPartidaSalva) ...[
          OutlinedButton(
            onPressed: onContinuar,
            child: Text(eIngles ? "Continue Game" : "Continuar Partida"),
          ),
          const SizedBox(height: 10),
          // Botão para reiniciar o jogo do zero
          TextButton.icon(
            onPressed: onReiniciar,
            icon: const Icon(Icons.refresh, color: Colors.orangeAccent, size: 18),
            label: Text(
              eIngles ? "Restart from Beginning" : "Reiniciar do Zero",
              style: const TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
        ],
        Focus(
          focusNode: menuButtonFocusNode,
          onKeyEvent: (node, event) {
            // Garante que ao pressionar Enter ou Espaço pelo teclado, o jogo inicie
            if (event is KeyDownEvent && 
               (event.logicalKey == LogicalKeyboardKey.enter || 
                event.logicalKey == LogicalKeyboardKey.space)) {
              onIniciar();
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: ElevatedButton.icon(
            onPressed: onIniciar,
            icon: const Icon(Icons.play_arrow_rounded, size: 30),
            label: Text(
              eIngles ? "START" : "COMEÇAR", 
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade500,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              elevation: 10,
              shadowColor: Colors.green.shade900,
            ),
          ),
        ),
      ],
    );
  }
}