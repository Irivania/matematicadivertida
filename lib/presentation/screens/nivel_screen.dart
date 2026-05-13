import 'package:flutter/material.dart';
import 'package:matematicadivertida/presentation/routes/app_routes.dart';
import 'package:matematicadivertida/core/enums/nivel_enum.dart';
import 'package:matematicadivertida/core/enums/nivel_ext.dart';
import 'package:matematicadivertida/core/theme/app_colors.dart';

class NivelScreen extends StatelessWidget {
  const NivelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Recebe o perfil com segurança (evita erro se vier nulo)
    final args = ModalRoute.of(context)!.settings.arguments;
    final String perfil = args is String ? args : "Convidado";

    return Scaffold(
      backgroundColor: AppColors.backgroundEscuro,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "DESAFIO: ${perfil.toUpperCase()}",
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
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Text(
                "Selecione sua dificuldade:",
                style: TextStyle(color: Colors.white70, fontSize: 18),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: Nivel.values.length,
                itemBuilder: (context, index) {
                  final nivel = Nivel.values[index];
                  return _buildNivelCard(context, nivel, perfil);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNivelCard(BuildContext context, Nivel nivel, String perfil) {
    // Usamos as propriedades que criamos na NivelExt (nivel_ext.dart)
    // Isso reduz o código aqui e centraliza a lógica no Enum
    final Color corNivel = nivel.cor;
    
    // Ícones específicos para a progressão
    IconData iconeNivel;
    switch (nivel) {
      case Nivel.bronze:
        iconeNivel = Icons.bolt_outlined;
        break;
      case Nivel.prata:
        iconeNivel = Icons.workspace_premium_outlined;
        break;
      case Nivel.ouro:
        iconeNivel = Icons.whatshot_rounded;
        break;
      case Nivel.platina:
        iconeNivel = Icons.diamond_outlined;
        break;
      case Nivel.mestre:
        iconeNivel = Icons.auto_awesome;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            AppRoutes.jogo,
            arguments: {
              "perfil": perfil,
              "nivel": nivel, // Passamos o Enum completo em vez de string
            },
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: corNivel.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: corNivel.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconeNivel, color: corNivel, size: 30),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    Text(
                      "Indicado para: ${nivel.serie}",
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