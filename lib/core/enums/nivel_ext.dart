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
        return "5º ano";
      case Nivel.prata:
        return "6º–7º ano";
      case Nivel.ouro:
        return "8º–9º ano";
      case Nivel.platina:
        return "1º–2º EM";
      case Nivel.mestre:
        return "3º EM";
    }
  }
}