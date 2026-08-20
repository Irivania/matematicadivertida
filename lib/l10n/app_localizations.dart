import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// No description provided for @tituloLoja.
  ///
  /// In pt, this message translates to:
  /// **'Loja'**
  String get tituloLoja;

  /// No description provided for @modoTreino.
  ///
  /// In pt, this message translates to:
  /// **'MODO TREINO 📚'**
  String get modoTreino;

  /// No description provided for @modoDisputa.
  ///
  /// In pt, this message translates to:
  /// **'MODO DISPUTA 🏆'**
  String get modoDisputa;

  /// No description provided for @rankingGlobal.
  ///
  /// In pt, this message translates to:
  /// **'RANKING GLOBAL 🌍'**
  String get rankingGlobal;

  /// No description provided for @boasVindas.
  ///
  /// In pt, this message translates to:
  /// **'OLÁ, {nome}!'**
  String boasVindas(Object nome);

  /// No description provided for @missaoDiaria.
  ///
  /// In pt, this message translates to:
  /// **'MISSÃO DIÁRIA 🎯'**
  String get missaoDiaria;

  /// No description provided for @missaoConcluida.
  ///
  /// In pt, this message translates to:
  /// **'MISSÃO CONCLUÍDA! 🎉'**
  String get missaoConcluida;

  /// No description provided for @recompensaRecebida.
  ///
  /// In pt, this message translates to:
  /// **'Recompensa recebida: +200 XP! Volte amanhã! 📅'**
  String get recompensaRecebida;

  /// No description provided for @progressoQuestao.
  ///
  /// In pt, this message translates to:
  /// **'{atual}/{meta} questões - Complete para ganhar 200 XP'**
  String progressoQuestao(Object atual, Object meta);

  /// No description provided for @perguntaLabel.
  ///
  /// In pt, this message translates to:
  /// **'Pergunta'**
  String get perguntaLabel;

  /// No description provided for @deLabel.
  ///
  /// In pt, this message translates to:
  /// **'de'**
  String get deLabel;

  /// No description provided for @botaoContinuar.
  ///
  /// In pt, this message translates to:
  /// **'CONTINUAR'**
  String get botaoContinuar;

  /// No description provided for @botaoEntendi.
  ///
  /// In pt, this message translates to:
  /// **'ENTENDI'**
  String get botaoEntendi;

  /// No description provided for @continuarPartida.
  ///
  /// In pt, this message translates to:
  /// **'Continuar Partida'**
  String get continuarPartida;

  /// No description provided for @botaoComecar.
  ///
  /// In pt, this message translates to:
  /// **'COMEÇAR'**
  String get botaoComecar;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
