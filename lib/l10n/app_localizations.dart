import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_cy.dart';
import 'app_localizations_da.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_is.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_nb.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

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
    Locale('ar'),
    Locale('cy'),
    Locale('da'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('is'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('nb'),
    Locale('nl'),
    Locale('pl'),
    Locale('pt'),
    Locale('ro'),
    Locale('ru'),
    Locale('sv'),
    Locale('tr'),
    Locale('zh')
  ];

  /// No description provided for @helloWorld.
  ///
  /// In es, this message translates to:
  /// **'Hola Mundo!'**
  String get helloWorld;

  /// No description provided for @collections.
  ///
  /// In es, this message translates to:
  /// **'Colecciones'**
  String get collections;

  /// No description provided for @downloads.
  ///
  /// In es, this message translates to:
  /// **'Descargas'**
  String get downloads;

  /// No description provided for @liked.
  ///
  /// In es, this message translates to:
  /// **'Gustó'**
  String get liked;

  /// No description provided for @subscriptions.
  ///
  /// In es, this message translates to:
  /// **'Suscripciones'**
  String get subscriptions;

  /// No description provided for @filterBarText.
  ///
  /// In es, this message translates to:
  /// **'¿A donde quieres ir?'**
  String get filterBarText;

  /// No description provided for @editProfile.
  ///
  /// In es, this message translates to:
  /// **'Editar perfil'**
  String get editProfile;

  /// No description provided for @changeLanguage.
  ///
  /// In es, this message translates to:
  /// **'Cambiar idioma'**
  String get changeLanguage;

  /// No description provided for @downloadQR.
  ///
  /// In es, this message translates to:
  /// **'Descargar con QR'**
  String get downloadQR;

  /// No description provided for @login.
  ///
  /// In es, this message translates to:
  /// **'Iniciar sesión'**
  String get login;

  /// No description provided for @titleProfile.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get titleProfile;

  /// No description provided for @userName.
  ///
  /// In es, this message translates to:
  /// **'Nombre de usuario'**
  String get userName;

  /// No description provided for @userPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get userPassword;

  /// No description provided for @forgotPassword.
  ///
  /// In es, this message translates to:
  /// **'¿Se te olvidó tu contraseña?'**
  String get forgotPassword;

  /// No description provided for @recoverPassword.
  ///
  /// In es, this message translates to:
  /// **'recupéralo aquí'**
  String get recoverPassword;

  /// No description provided for @name.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get name;

  /// No description provided for @userBirthYear.
  ///
  /// In es, this message translates to:
  /// **'Año de nacimiento'**
  String get userBirthYear;

  /// No description provided for @userGender.
  ///
  /// In es, this message translates to:
  /// **'Género'**
  String get userGender;

  /// No description provided for @userNationality.
  ///
  /// In es, this message translates to:
  /// **'Nacionalidad'**
  String get userNationality;

  /// No description provided for @titleInterest.
  ///
  /// In es, this message translates to:
  /// **'Intereses'**
  String get titleInterest;

  /// No description provided for @titleExplore.
  ///
  /// In es, this message translates to:
  /// **'Explorar'**
  String get titleExplore;

  /// No description provided for @titleMap.
  ///
  /// In es, this message translates to:
  /// **'Mapa'**
  String get titleMap;

  /// No description provided for @genderMale.
  ///
  /// In es, this message translates to:
  /// **'Masculino'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In es, this message translates to:
  /// **'Mujer'**
  String get genderFemale;

  /// No description provided for @genderOther.
  ///
  /// In es, this message translates to:
  /// **'Otro'**
  String get genderOther;

  /// No description provided for @subtitleRecommend.
  ///
  /// In es, this message translates to:
  /// **'Recomendado para ti'**
  String get subtitleRecommend;

  /// No description provided for @subtitlePopular.
  ///
  /// In es, this message translates to:
  /// **'Lugares populares'**
  String get subtitlePopular;

  /// No description provided for @subtitleRestaurants.
  ///
  /// In es, this message translates to:
  /// **'Restaurantes'**
  String get subtitleRestaurants;

  /// No description provided for @userCreate.
  ///
  /// In es, this message translates to:
  /// **'Crear una cuenta'**
  String get userCreate;

  /// No description provided for @chatTitle.
  ///
  /// In es, this message translates to:
  /// **'Chat'**
  String get chatTitle;

  /// No description provided for @recommendations.
  ///
  /// In es, this message translates to:
  /// **'Recomendaciones'**
  String get recommendations;

  /// No description provided for @rateThisTour.
  ///
  /// In es, this message translates to:
  /// **'Califica este tour'**
  String get rateThisTour;

  /// No description provided for @describeYourExperience.
  ///
  /// In es, this message translates to:
  /// **'Describe tu experiencia'**
  String get describeYourExperience;

  /// No description provided for @submit.
  ///
  /// In es, this message translates to:
  /// **'Entregar'**
  String get submit;

  /// No description provided for @categoryHotel.
  ///
  /// In es, this message translates to:
  /// **'Hotel'**
  String get categoryHotel;

  /// No description provided for @categoryRestaurant.
  ///
  /// In es, this message translates to:
  /// **'Restaurantes'**
  String get categoryRestaurant;

  /// No description provided for @categoryActivities.
  ///
  /// In es, this message translates to:
  /// **'Ocupaciones'**
  String get categoryActivities;

  /// No description provided for @categoryPark.
  ///
  /// In es, this message translates to:
  /// **'parques'**
  String get categoryPark;

  /// No description provided for @categoryNightActivities.
  ///
  /// In es, this message translates to:
  /// **'Actividades Nocturnas'**
  String get categoryNightActivities;

  /// No description provided for @categoryChurch.
  ///
  /// In es, this message translates to:
  /// **'Iglesia'**
  String get categoryChurch;

  /// No description provided for @categoryMuseums.
  ///
  /// In es, this message translates to:
  /// **'Museos'**
  String get categoryMuseums;

  /// No description provided for @email.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get email;

  /// No description provided for @logout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get logout;

  /// No description provided for @goBackToLogin.
  ///
  /// In es, this message translates to:
  /// **'Volver a'**
  String get goBackToLogin;

  /// No description provided for @recoverPasswordButton.
  ///
  /// In es, this message translates to:
  /// **'Recuperar contraseña'**
  String get recoverPasswordButton;

  /// No description provided for @signup.
  ///
  /// In es, this message translates to:
  /// **'Inscribirse'**
  String get signup;

  /// No description provided for @confirmUserPassword.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get confirmUserPassword;

  /// No description provided for @noTourFoundText.
  ///
  /// In es, this message translates to:
  /// **'Ningún recorrido cumple con los criterios'**
  String get noTourFoundText;

  /// No description provided for @recoverPasswordMessage.
  ///
  /// In es, this message translates to:
  /// **'Le hemos enviado un correo electrónico para restablecer su contraseña.'**
  String get recoverPasswordMessage;

  /// No description provided for @emailRequired.
  ///
  /// In es, this message translates to:
  /// **'Debe introducir una dirección de correo electrónico.'**
  String get emailRequired;

  /// No description provided for @createUserMessage.
  ///
  /// In es, this message translates to:
  /// **'Usuario creado. Inicie sesión para editar sus preferencias.'**
  String get createUserMessage;

  /// No description provided for @weakPasswordMessage.
  ///
  /// In es, this message translates to:
  /// **'La contraseña debe tener al menos 6 caracteres.'**
  String get weakPasswordMessage;

  /// No description provided for @emailAlreadyExistsMessage.
  ///
  /// In es, this message translates to:
  /// **'Esta cuenta de correo electrónico ya fue usada.'**
  String get emailAlreadyExistsMessage;

  /// No description provided for @loginSuccessful.
  ///
  /// In es, this message translates to:
  /// **'Inicio de sesión correcto'**
  String get loginSuccessful;

  /// No description provided for @noUserWithThisEmailMessage.
  ///
  /// In es, this message translates to:
  /// **'Ningún usuario registrado con este correo electrónico.'**
  String get noUserWithThisEmailMessage;

  /// No description provided for @wrongPasswordMessage.
  ///
  /// In es, this message translates to:
  /// **'Correo o contraseña incorrectos.'**
  String get wrongPasswordMessage;

  /// No description provided for @recommendRoute.
  ///
  /// In es, this message translates to:
  /// **'¡Construye tu ruta!'**
  String get recommendRoute;

  /// No description provided for @morning.
  ///
  /// In es, this message translates to:
  /// **'Mañana'**
  String get morning;

  /// No description provided for @midday.
  ///
  /// In es, this message translates to:
  /// **'Mediodía'**
  String get midday;

  /// No description provided for @evening.
  ///
  /// In es, this message translates to:
  /// **'Noche'**
  String get evening;

  /// No description provided for @cancelRoute.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancelRoute;

  /// No description provided for @confirmRoute.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get confirmRoute;

  /// No description provided for @nextRoute.
  ///
  /// In es, this message translates to:
  /// **'próximo'**
  String get nextRoute;

  /// No description provided for @shareInitialText.
  ///
  /// In es, this message translates to:
  /// **'Increíble experiencia en'**
  String get shareInitialText;

  /// No description provided for @shareSecondPartText.
  ///
  /// In es, this message translates to:
  /// **'Echa un vistazo a esta NgenApp'**
  String get shareSecondPartText;

  /// No description provided for @downloadFullTour.
  ///
  /// In es, this message translates to:
  /// **'Descargar Tour Completo'**
  String get downloadFullTour;

  /// No description provided for @cancelDownloadTour.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancelDownloadTour;

  /// No description provided for @downloadTourAction.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get downloadTourAction;

  /// No description provided for @nextStep.
  ///
  /// In es, this message translates to:
  /// **'Próximo paso'**
  String get nextStep;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'ar',
        'cy',
        'da',
        'de',
        'en',
        'es',
        'fr',
        'is',
        'it',
        'ja',
        'ko',
        'nb',
        'nl',
        'pl',
        'pt',
        'ro',
        'ru',
        'sv',
        'tr',
        'zh'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'cy':
      return AppLocalizationsCy();
    case 'da':
      return AppLocalizationsDa();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'is':
      return AppLocalizationsIs();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'nb':
      return AppLocalizationsNb();
    case 'nl':
      return AppLocalizationsNl();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ro':
      return AppLocalizationsRo();
    case 'ru':
      return AppLocalizationsRu();
    case 'sv':
      return AppLocalizationsSv();
    case 'tr':
      return AppLocalizationsTr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
