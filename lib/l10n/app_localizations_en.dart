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
  String get missaoConcluida => 'MISSION COMPLETED! 🎉';

  @override
  String get recompensaRecebida =>
      'Reward received: +200 XP! Come back tomorrow! 📅';

  @override
  String progressoQuestao(Object atual, Object meta) {
    return '$atual/$meta questions - Complete to earn 200 XP';
  }

  @override
  String get perguntaLabel => 'Pergunta';

  @override
  String get deLabel => 'de';

  @override
  String get botaoContinuar => 'CONTINUAR';

  @override
  String get botaoEntendi => 'ENTENDI';

  @override
  String get continuarPartida => 'Continuar Partida';

  @override
  String get botaoComecar => 'COMEÇAR';
}
