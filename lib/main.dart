import 'package:app/core/config/app_environment.dart';
import 'package:app/core/theme/ngen_theme.dart';
import 'package:app/core/locale/supported_app_locales.dart';
import 'package:app/core/storage/localstorage_compat.dart';
import 'package:app/core/tour/tour_qr_handler.dart';
import 'package:app/providers/locale_provider.dart';
import 'package:app/src/not_found.dart';
import 'package:app/src/start_up_logic.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'src/navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initLocalStorage();
  await Firebase.initializeApp();
  await AppEnvironment.load();
  await AppEnvironment.connectFirebaseEmulators();
  final User? user = await AppEnvironment.ensureSignedIn();
  localStorage.setItem('user', user.toString());
  runApp(NgenApp(isLocalEnv: AppEnvironment.isLocal));
}

final GlobalKey<NavigatorState> ngenNavigatorKey = GlobalKey<NavigatorState>();

class NgenApp extends StatelessWidget {
  const NgenApp({super.key, this.isLocalEnv = false});

  final bool isLocalEnv;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LocaleProvider()
            ..hydrateFromStorage(localStorage.getItem('locale') as String?),
        ),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, provider, __) {
          return TourQrHandler(
            navigatorKey: ngenNavigatorKey,
            child: MaterialApp(
            navigatorKey: ngenNavigatorKey,
            debugShowCheckedModeBanner: false,
            title: 'NgenApp',
            builder: (context, child) {
              if (!isLocalEnv || child == null) return child ?? const SizedBox.shrink();
              return Banner(
                message: 'LOCAL',
                location: BannerLocation.topEnd,
                color: Colors.orange.shade800,
                child: child,
              );
            },
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            locale: provider.locale ?? SupportedAppLocales.normalize(localStorage.getItem('locale') as String?),
            supportedLocales: SupportedAppLocales.materialLocales,
            theme: NgenTheme.light(),
            home: StartupLogic().getLandingPage(context),
            routes: {
              "/home": (_) => Navigation(),
              "/not-found": (_) => NotFoundWidget(),
            },
          ),
          );
        },
      ),
    );
  }
}

