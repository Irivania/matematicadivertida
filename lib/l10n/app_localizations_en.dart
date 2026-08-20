// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get tituloLoja => 'Shop';

  @override
  String get modoTreino => 'TRAINING MODE 📚';

  @override
  String get modoDisputa => 'CHALLENGE MODE 🏆';

  @override
  String get rankingGlobal => 'GLOBAL RANKING 🌍';

  @override
  String boasVindas(Object nome) {
    return 'HELLO, $nome!';
  }

  @override
  String get missaoDiaria => 'DAILY MISSION 🎯';

  @override
  String get progressoQuestao => 'questions - Complete to earn 200 XP';
}
