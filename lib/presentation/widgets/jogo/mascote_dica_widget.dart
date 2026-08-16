// lib/presentation/widgets/jogo/mascote_dica_widget.dart
import 'package:flutter/material.dart';

class MascoteDicaWidget extends StatelessWidget {
  final VoidCallback onExibirDica;

  const MascoteDicaWidget({
    super.key,
    required this.onExibirDica,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onExibirDica,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "DICA DO CAL", 
            style: TextStyle(
              color: Colors.red, 
              fontSize: 14, 
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: Colors.black, blurRadius: 2)],
            ),
          ),
          const SizedBox(height: 4),
          // Usamos o SizedBox para forçar o tamanho exato desejado na tela
          SizedBox(
            width: 300, 
            height: 300,
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle, 
                boxShadow: [
                  BoxShadow(
                    color: Colors.white24, 
                    blurRadius: 15, 
                    spreadRadius: 3
                  )
                ],
              ),
              child: Image.asset(
                'assets/images/mascote_cal.png', 
                fit: BoxFit.contain, 
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.smart_toy, 
                  size: 150, 
                  color: Colors.white
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}