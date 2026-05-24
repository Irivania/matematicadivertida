import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class GameModeButton extends StatefulWidget {
  final String titulo;
  final String subtitulo;
  final Color cor;
  final VoidCallback onPressed;

  const GameModeButton({
    super.key,
    required this.titulo,
    required this.subtitulo,
    required this.cor,
    required this.onPressed,
  });

  @override
  State<GameModeButton> createState() => _GameModeButtonState();
}

class _GameModeButtonState extends State<GameModeButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: SizedBox(
        width: double.infinity,
        height: 64,
        child: ElevatedButton(
          onPressed: () async {
            _controller.forward(); // Inicia a animação
            await Future.delayed(const Duration(milliseconds: 150));
            _controller.reverse(); // Volta ao normal
            widget.onPressed();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.cor,
            foregroundColor: AppColors.backgroundEscuro,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(widget.titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(widget.subtitulo, style: TextStyle(fontSize: 11, color: AppColors.backgroundEscuro.withOpacity(0.7))),
            ],
          ),
        ),
      ),
    );
  }
}