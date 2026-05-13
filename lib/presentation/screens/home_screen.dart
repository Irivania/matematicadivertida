import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../../core/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundEscuro,
      body: Stack(
        children: [
          // Efeito de brilho de fundo (Glow)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.neonCiano.withOpacity(0.15),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo ou Título Estilizado
                  const Icon(
                    Icons.calculate_rounded,
                    size: 100,
                    color: AppColors.neonCiano,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "MATEMÁTICA\nDIVERTIDA",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 4,
                    width: 60,
                    decoration: BoxDecoration(
                      color: AppColors.neonCiano,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 60),

                  // Botão Principal com Efeito Neon
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.perfil),
                    child: Container(
                      width: double.infinity,
                      height: 65,
                      decoration: BoxDecoration(
                        color: AppColors.neonCiano,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonCiano.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "INICIAR JORNADA",
                          style: TextStyle(
                            color: AppColors.backgroundEscuro,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Botão Secundário (Configurações ou Ranking)
                  OutlinedButton(
                    onPressed: () {
                      // Espaço para futuras implementações como Ranking
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 60),
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "RANKING GLOBAL",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Versão do App no rodapé
          const Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Text(
              "v1.0.0+1",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white24, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}