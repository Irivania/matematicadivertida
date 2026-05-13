// lib/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
// IMPORTANTE: Importe a tela de ranking que criamos no passo anterior
import 'ranking_screen.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundEscuro,
      body: Stack(
        children: [
          // Efeito de brilho de fundo (Glow)
          _buildBackgroundGlow(),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 60),

                  // Botão Principal: Iniciar Jornada
                  _buildPrimaryButton(context),

                  const SizedBox(height: 20),

                  // Botão Secundário: Ranking Global (INTEGRADO)
                  _buildRankingButton(context),
                ],
              ),
            ),
          ),
          
          _buildVersionFooter(),
        ],
      ),
    );
  }

  // --- Widgets Refatorados para Limpeza do Build ---

  Widget _buildBackgroundGlow() {
    return Positioned(
      top: -100,
      right: -100,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.neonCiano.withValues(alpha: 0.15),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
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
      ],
    );
  }

  Widget _buildPrimaryButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () => Navigator.pushNamed(context, AppRoutes.perfil),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.neonCiano,
        foregroundColor: AppColors.backgroundEscuro,
        minimumSize: const Size(double.infinity, 65),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0, // Sombra personalizada via Container se desejar glow
      ).copyWith(
        // Adicionando o efeito de sombra neon via estado
        shadowColor: WidgetStateProperty.all(AppColors.neonCiano.withValues(alpha: 0.4)),
      ),
      child: const Text(
        "INICIAR JORNADA",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildRankingButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        // Navegação direta para a tela de Ranking
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RankingScreen()),
        );
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
        style: TextStyle(color: Colors.white70, fontSize: 16),
      ),
    );
  }

  Widget _buildVersionFooter() {
    return const Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Text(
        "v1.0.0+1",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white24, fontSize: 12),
      ),
    );
  }
}