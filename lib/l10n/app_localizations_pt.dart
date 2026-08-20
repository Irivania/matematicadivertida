// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get tituloLoja => 'Loja';

  @override
  String get modoTreino => 'MODO TREINO 📚';

  @override
  String get modoDisputa => 'MODO DISPUTA 🏆';

  @override
  String get rankingGlobal => 'RANKING GLOBAL 🌍';

  @override
  String boasVindas(Object nome) {
    return 'OLÁ, $nome!';
  }

  @override
  String get missaoDiaria => 'MISSÃO DIÁRIA 🎯';

  @override
  String get progressoQuestao => 'questões - Complete para ganhar 200 XP';
}
