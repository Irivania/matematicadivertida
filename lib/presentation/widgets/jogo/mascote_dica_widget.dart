// lib/presentation/widgets/jogo/mascote_dica_widget.dart
import 'package:flutter/material.dart';

class MascoteDicaWidget extends StatefulWidget {
  final VoidCallback onExibirDica;

  const MascoteDicaWidget({
    super.key,
    required this.onExibirDica,
  });

  @override
  State<MascoteDicaWidget> createState() => _MascoteDicaWidgetState();
}

class _MascoteDicaWidgetState extends State<MascoteDicaWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Configura a animação de pulsação (entre 0.95 e 1.05 do tamanho original)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onExibirDica,
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
          // Aplica a animação de escala
          ScaleTransition(
            scale: _animation,
            child: SizedBox(
              width: 150,
              height: 150,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white24,
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/mascote_cal.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.smart_toy,
                    size: 150,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}