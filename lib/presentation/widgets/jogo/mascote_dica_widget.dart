// lib/presentation/widgets/jogo/mascote_dica_widget.dart
import 'package:flutter/material.dart';

class MascoteDicaWidget extends StatelessWidget {
  final VoidCallback onExibirDica;

  // Removi o 'perfil' daqui pois ele não estava sendo usado no build
  const MascoteDicaWidget({
    super.key,
    required this.onExibirDica,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // O 'opaque' garante que qualquer parte do widget capture o toque
      behavior: HitTestBehavior.opaque,
      onTap: onExibirDica,
      child: Column(
        mainAxisSize: MainAxisSize.min, // Garante que o widget não ocupe espaço desnecessário
        children: [
          const Text(
            "DICA DO CAL", 
            style: TextStyle(
              color: Colors.red, 
              fontSize: 12, 
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black, blurRadius: 2)],
            ),
          ),
          const SizedBox(height: 4),
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle, 
              boxShadow: [
                BoxShadow(
                  color: Colors.white24, 
                  blurRadius: 10, 
                  spreadRadius: 2
                )
              ],
            ),
            child: Image.asset(
              'assets/images/mascote_cal.png', 
              width: 80, 
              height: 80, 
              fit: BoxFit.contain, 
              errorBuilder: (_, __, ___) => const Icon(
                Icons.smart_toy, 
                size: 60, 
                color: Colors.white
              ),
            ),
          ),
        ],
      ),
    );
  }
}