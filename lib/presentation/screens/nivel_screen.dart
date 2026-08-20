// lib/presentation/screens/nivel_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:matematicadivertida/presentation/routes/app_routes.dart';
import 'package:matematicadivertida/core/enums/nivel_enum.dart';
import 'package:matematicadivertida/core/enums/nivel_ext.dart';
import 'package:matematicadivertida/core/theme/app_colors.dart';
import 'package:matematicadivertida/data/models/game_state.dart';

class NivelScreen extends StatelessWidget {
  const NivelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    final String perfil = args is String ? args : "Convidado";

    // Verifica o idioma atual para tradução
    final gameState = context.watch<GameState>();
    final bool eIngles = gameState.currentLocale.languageCode == 'en';

    return Scaffold(
      backgroundColor: AppColors.backgroundEscuro,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          eIngles ? "CHALLENGE: ${perfil.toUpperCase()}" : "DESAFIO: ${perfil.toUpperCase()}",
          style: const TextStyle(
            color: AppColors.neonCiano,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.neonCiano),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Text(
                eIngles ? "Select your difficulty:" : "Selecione sua dificuldade:",
                style: const TextStyle(color: Colors.white70, fontSize: 18),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: Nivel.values.length,
                itemBuilder: (context, index) {
                  final nivel = Nivel.values[index];
                  return _buildNivelCard(context, nivel, perfil, eIngles);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNivelCard(BuildContext context, Nivel nivel, String perfil, bool eIngles) {
    final gameState = context.watch<GameState>();
    final Color corNivel = nivel.cor;
    
    final String medalha = gameState.obterTipoMedalha(nivel.name); 

    IconData iconeNivel = switch (nivel) {
      Nivel.bronze => Icons.bolt_outlined,
      Nivel.prata => Icons.workspace_premium_outlined,
      Nivel.ouro => Icons.whatshot_rounded,
      Nivel.platina => Icons.diamond_outlined,
      Nivel.mestre => Icons.auto_awesome,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.jogo,
            arguments: {
              "perfil": perfil,
              "nivel": nivel,
            },
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: corNivel.withOpacity(0.3), width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: corNivel.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconeNivel, color: corNivel, size: 30),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          nivel.label.toUpperCase(),
                          style: TextStyle(
                            color: corNivel,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (medalha.isNotEmpty)
                          Text(medalha, style: const TextStyle(fontSize: 14, color: Colors.amber)),
                      ],
                    ),
                    Text(
                      eIngles ? "Recommended for: ${nivel.serie}" : "Indicado para: ${nivel.serie}",
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}