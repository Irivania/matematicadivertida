import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PerfilCard extends StatelessWidget {
  final String label;
  final String img;
  final VoidCallback onTap;

  const PerfilCard({
    super.key,
    required this.label,
    required this.img,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Usamos um ValueNotifier local para controlar o hover de forma limpa
    final ValueNotifier<bool> isHovered = ValueNotifier(false);

    return MouseRegion(
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: GestureDetector(
        onTap: onTap,
        child: ValueListenableBuilder<bool>(
          valueListenable: isHovered,
          builder: (context, hovered, _) {
            return AnimatedScale(
              scale: hovered ? 1.12 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 210, height: 270,
                decoration: BoxDecoration(
                  color: hovered ? Colors.white.withOpacity(0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(img, height: 190, fit: BoxFit.contain),
                    const SizedBox(height: 12),
                    Text(label, textAlign: TextAlign.center, 
                         style: GoogleFonts.fredoka(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18, 
                         shadows: [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 5)])),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}