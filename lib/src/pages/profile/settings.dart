import 'package:app/providers/locale_provider.dart';
import 'package:app/src/pages/profile/edit_profile.dart';
import 'package:app/src/pages/profile/languages_screen.dart';
import 'package:app/src/pages/profile/login/login.dart';
import 'package:app/src/util/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app/core/storage/localstorage_compat.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:provider/provider.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class SettingsWidget extends StatefulWidget {
  @override
  _SettingsWidgetState createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  final LocalStorage storage = new LocalStorage('ngen_app');
  final GoogleSignIn googleSignIn = GoogleSignIn();
  FirebaseAuth auth = FirebaseAuth.instance;
  bool isAnonymous = true;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    checkAnonymous();
  }

  void checkAnonymous() {
    if (this.mounted) {
      setState(() {
        isAnonymous = auth.currentUser == null || auth.currentUser!.isAnonymous;
      });
    }
  }

  void signOut() async {
    setState(() {
      loading = true;
    });
    await FirebaseAuth.instance.signOut();
    await googleSignIn.signOut();
    await FacebookAuth.instance.logOut();
    await Future.delayed(Duration(seconds: 1));
    await FirebaseAuth.instance.signInAnonymously();
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    checkAnonymous();
    return Scaffold(
        appBar: AppBar(
          elevation: 1,
          title: Text(
            AppLocalizations.of(context)!.titleProfile,
            style: TextStyle(color: AppColors.font_black, fontWeight: FontWeight.w600),
          ),
          backgroundColor: AppColors.white,
        ),
        body: FutureBuilder(
            future: storage.ready,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Consumer<LocaleProvider>(builder: (context, provider, snapshot) {
                return buildSettingsList(context, provider, storage.getItem('locale') ?? 'en');
              });
            }));
  }

  Widget buildSettingsList(BuildContext context, LocaleProvider provider, String locale) {
    var languages = [
      {"name": "English", "code": "en"},
      {"name": "Español", "code": "es"},
      {"name": "Français", "code": "fr"},
      {"name": "Deutsch", "code": "de"},
      {"code": 'nl', "name": 'Nederlands'},
      {"code": 'ru', "name": 'русский'},
      {"name": "Italiano", "code": "it"},
      {"name": "Português", "code": "pt"},
      {"code": 'cy', "name": 'Cymraeg'},
      {"code": 'is', "name": 'Íslenska'},
      {"code": 'sv', "name": 'Svenska'},
      {"code": 'ro', "name": 'Română'},
      {"code": 'pl', "name": 'Język Polski'},
      {"code": 'tr', "name": 'Türkçe'},
      {"code": 'da', "name": 'Dansk'},
      {"code": 'nb', "name": 'Norsk'},
      {"code": 'ar', "name": 'اَلْعَرَبِيَّةُ'},
      {"name": "日本語", "code": "ja"},
      {"code": 'ko', "name": '한국어 / 조선말'},
      {"name": "中文", "code": "zh"},
    ];

    String codeToString(String locale) {
      final lang = languages.where((element) => element["code"] == locale);
      if (lang.isEmpty) return 'English';
      final name = lang.first["name"];
      return name is String ? name : '$name';
    }

    final String langCode = provider.locale?.languageCode ?? locale;
    return SettingsList(
      lightTheme: const SettingsThemeData(settingsListBackground: AppColors.white),
      sections: [
        SettingsSection(
          tiles: [
            SettingsTile(
                enabled: !isAnonymous,
                title: Text(AppLocalizations.of(context)!.editProfile),
                leading: Icon(
                  MdiIcons.accountCogOutline,
                  color: !isAnonymous ? AppColors.primary : AppColors.font_light,
                ),
                trailing: Icon(
                  MdiIcons.chevronRight,
                  color: !isAnonymous ? AppColors.primary : AppColors.font_light,
                ),
                onPressed: (context) {
                  Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => EditProfile(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(2.0, 0.0);
                      const end = Offset.zero;
                      const curve = Curves.fastLinearToSlowEaseIn;

                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                  ));
                }),
            SettingsTile(
              title: Text(AppLocalizations.of(context)!.changeLanguage),
              description: Text(codeToString(langCode)),
              leading: Icon(
                MdiIcons.translate,
                color: AppColors.primary,
              ),
              trailing: Icon(
                MdiIcons.chevronRight,
                color: AppColors.primary,
              ),
              onPressed: (context) {
                Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => LanguagesScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(2.0, 0.0);
                    const end = Offset.zero;
                    const curve = Curves.fastLinearToSlowEaseIn;

                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                    return SlideTransition(
                      position: animation.drive(tween),
                      child: child,
                    );
                  },
                ));
              },
            ),
            // SettingsTile(
            //   title: 'Preguntas frecuentes',
            //   leading: Icon(
            //     MdiIcons.cloudQuestion,
            //     color: AppColors.primary,
            //   ),
            //   trailing: Icon(
            //     MdiIcons.chevronRight,
            //     color: AppColors.primary,
            //   ),
            // ),
            // SettingsTile(
            //   title: AppLocalizations.of(context)!.downloadQR,
            //   leading: Icon(
            //     MdiIcons.qrcode,
            //     color: AppColors.primary,
            //   ),
            //   trailing: Icon(
            //     MdiIcons.chevronRight,
            //     color: AppColors.primary,
            //   ),
            // ),
            SettingsTile(
                enabled: !loading,
                title: Text(isAnonymous ? AppLocalizations.of(context)!.login : AppLocalizations.of(context)!.logout),
                leading: loading
                    ? CircularProgressIndicator()
                    : Icon(
                        MdiIcons.exitToApp,
                        color: AppColors.primary,
                      ),
                onPressed: (context) {
                  if (isAnonymous) {
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        const begin = Offset(2.0, 0.0);
                        const end = Offset.zero;
                        const curve = Curves.fastLinearToSlowEaseIn;

                        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ));
                  } else {
                    signOut();
                  }
                }),
          ],
        ),
      ],
    );
  }
}

