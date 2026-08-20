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
  String get missaoConcluida => 'MISSÃO CONCLUÍDA! 🎉';

  @override
  String get recompensaRecebida =>
      'Recompensa recebida: +200 XP! Volte amanhã! 📅';

  @override
  String progressoQuestao(Object atual, Object meta) {
    return '$atual/$meta questões - Complete para ganhar 200 XP';
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
