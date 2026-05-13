import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum Nivel {
  bronze(
    label: 'Bronze',
    cor: Colors.orange, // Ou use AppColors.bronze se tiver definido
    icone: Icons.star_border,
    multiplicadorXP: 1.0,
  ),
  prata(
    label: 'Prata',
    cor: Colors.grey,
    icone: Icons.star_half,
    multiplicadorXP: 1.2,
  ),
  ouro(
    label: 'Ouro',
    cor: Colors.amber,
    icone: Icons.star,
    multiplicadorXP: 1.5,
  ),
  platina(
    label: 'Platina',
    cor: Colors.cyan,
    icone: Icons.workspace_premium,
    multiplicadorXP: 2.0,
  ),
  mestre(
    label: 'Mestre',
    cor: AppColors.neonRoxo,
    icone: Icons.military_tech,
    multiplicadorXP: 3.0,
  );

  final String label;
  final Color cor;
  final IconData icone;
  final double multiplicadorXP;

  const Nivel({
    required this.label,
    required this.cor,
    required this.icone,
    required this.multiplicadorXP,
  });
}