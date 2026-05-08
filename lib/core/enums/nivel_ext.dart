import 'nivel_enum.dart';

extension NivelExt on Nivel {
  String get nome {
    switch (this) {
      case Nivel.bronze:
        return "Bronze";
      case Nivel.prata:
        return "Prata";
      case Nivel.ouro:
        return "Ouro";
      case Nivel.platina:
        return "Platina";
      case Nivel.mestre:
        return "Mestre";
    }
  }

  String get serie {
    switch (this) {
      case Nivel.bronze:
        return "1º ano";
      case Nivel.prata:
        return "2º ano";
      case Nivel.ouro:
        return "3º ano";
      case Nivel.platina:
        return "4º ano";
      case Nivel.mestre:
        return "5º ano";
    }
  }
}