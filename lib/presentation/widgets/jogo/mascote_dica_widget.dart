// lib/presentation/widgets/jogo/mascote_dica_widget.dart

import 'package:flutter/material.dart';

class MascoteDicaWidget extends StatelessWidget {
  final String perfil;
  final VoidCallback onExibirDica;

  const MascoteDicaWidget({
    super.key,
    required this.perfil,
    required this.onExibirDica,
  });

  @override
  Widget build(BuildContext context) {
    double bottomPos = perfil.toLowerCase().contains('crian') ? 130 : 150;
    
    return Positioned(
      bottom: bottomPos,
      right: 15, 
      child: GestureDetector(
        onTap: onExibirDica,
        child: Column(
          children: [
            const Text(
              "DICA DO MASCOTE", 
              style: TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle, 
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.8), 
                    blurRadius: 10, 
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Image.asset(
                'assets/images/mascote_cal.png', 
                width: 120, 
                height: 120, 
                fit: BoxFit.contain, 
                errorBuilder: (c, e, s) => const Icon(Icons.smart_toy, size: 60, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}