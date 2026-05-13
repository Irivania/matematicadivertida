import 'package:flutter/material.dart';
import 'nivel_enum.dart';

extension NivelExt on Nivel {
  // Retorna o nome amigável
  String get label {
    switch (this) {
      case Nivel.bronze: return "Bronze";
      case Nivel.prata:  return "Prata";
      case Nivel.ouro:   return "Ouro";
      case Nivel.platina: return "Platina";
      case Nivel.mestre:  return "Mestre";
    }
  }

  // Retorna a cor característica de cada nível (Necessário para os Diálogos e Cards)
  Color get cor {
    switch (this) {
      case Nivel.bronze: return const Color(0xFFCD7F32);
      case Nivel.prata:  return const Color(0xFFC0C0C0);
      case Nivel.ouro:   return const Color(0xFFFFD700);
      case Nivel.platina: return const Color(0xFFE5E4E2);
      case Nivel.mestre:  return const Color(0xFF9D00FF);
    }
  }

  // Retorna o ícone visual
  String get icone {
    switch (this) {
      case Nivel.bronze: return "🥉";
      case Nivel.prata:  return "🥈";
      case Nivel.ouro:   return "🥇";
      case Nivel.platina: return "💎";
      case Nivel.mestre:  return "🏆";
    }
  }

  // Define o bônus de pontuação
  double get multiplicadorXP {
    switch (this) {
      case Nivel.bronze: return 1.0;
      case Nivel.prata:  return 1.5;
      case Nivel.ouro:   return 2.0;
      case Nivel.platina: return 2.5;
      case Nivel.mestre:  return 3.0;
    }
  }

  // Retorna a série escolar correspondente
  String get serie {
    switch (this) {
      case Nivel.bronze: return "1º ano";
      case Nivel.prata:  return "2º ano";
      case Nivel.ouro:   return "3º ano";
      case Nivel.platina: return "4º ano";
      case Nivel.mestre:  return "5º ano";
    }
  }

  String get nome => label;
}