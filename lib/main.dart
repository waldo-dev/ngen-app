import 'package:app/core/storage/localstorage_compat.dart';
import 'package:app/providers/locale_provider.dart';
import 'package:app/src/not_found.dart';
import 'package:app/src/start_up_logic.dart';
import 'package:app/src/util/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:provider/provider.dart';

import 'src/navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initLocalStorage();
  await Firebase.initializeApp();
  await GlobalConfiguration().loadFromAsset("settings");
  final String mode = GlobalConfiguration().getValue("mode") != null ? GlobalConfiguration().getValue("mode") : 'production';
  if (mode == "development") {
    String host = GlobalConfiguration().getValue("host") != null ? GlobalConfiguration().getValue("host") : 'localhost';
    // Android AVD: localhost/127.0.0.1 → 10.0.2.2 (host machine). On a physical phone,
    // set "host" in assets/cfg/settings.json to your PC's LAN IP instead.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android && (host == 'localhost' || host == '127.0.0.1')) {
      host = '10.0.2.2';
    }
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    FirebaseFunctions.instance.useFunctionsEmulator(host, 5001);
  }
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    final UserCredential anonymousInstance = await FirebaseAuth.instance.signInAnonymously();
    user = anonymousInstance.user;
  }
  localStorage.setItem('user', user.toString());
  runApp(const NgenApp());
}

class NgenApp extends StatelessWidget {
  const NgenApp({super.key});

  static const MaterialColor myColor = MaterialColor(0xFF7225d7, {
    50: Color.fromRGBO(114, 37, 215, .1),
    100: Color.fromRGBO(114, 37, 215, .2),
    200: Color.fromRGBO(114, 37, 215, .3),
    300: Color.fromRGBO(114, 37, 215, .4),
    400: Color.fromRGBO(114, 37, 215, .5),
    500: Color.fromRGBO(114, 37, 215, .6),
    600: Color.fromRGBO(114, 37, 215, .7),
    700: Color.fromRGBO(114, 37, 215, .8),
    800: Color.fromRGBO(114, 37, 215, .9),
    900: Color.fromRGBO(114, 37, 215, 1),
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, _, __) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'NgenApp',
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            locale: Locale(localStorage.getItem('locale') ?? 'en'),
            supportedLocales: AppLocalizations.supportedLocales,
            theme: ThemeData(primaryColor: AppColors.primary, primarySwatch: myColor, fontFamily: "Open Sans"),
            home: StartupLogic().getLandingPage(context),
            routes: {
              "/home": (_) => Navigation(),
              "/not-found": (_) => NotFoundWidget(),
            },
          );
        },
      ),
    );
  }
}

