import 'package:app/providers/locale_provider.dart';
import 'package:app/src/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:app/core/storage/localstorage_compat.dart';

class LanguagesScreen extends StatefulWidget {
  @override
  _LanguagesScreenState createState() => _LanguagesScreenState();
}

class _LanguagesScreenState extends State<LanguagesScreen> {
  final LocalStorage storage = new LocalStorage('ngen_app');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: storage.ready,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return Consumer<LocaleProvider>(builder: (context, provider, snapshot) {
            var languages = [
              {"name": "English", "code": "en"},
              {"name": "Español", "code": "es"},
              {"name": "Français", "code": "fr"},
              {"name": "Deutsch", "code": "de"},
              {"code": 'nl', "name": 'Nederlands'},
              {"code": 'ru', "name": 'русский'},
              {"name": "Italiano", "code": "it"},
              {"name": "Português", "code": "pt"},
              // {"code": 'cy', "name": 'Cymraeg'},
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

            Widget trailingWidget(bool selectedLang) {
              return selectedLang ? Icon(Icons.check, color: AppColors.primary) : const SizedBox.shrink();
            }

            void changeLanguage(Locale? locale) async {
              provider.setLocale(locale!);
              storage.setItem('locale', locale.toString());
            }

            var lang = provider.locale ?? Localizations.localeOf(context);
            return Scaffold(
              appBar: AppBar(
                elevation: 1,
                title: Text(
                  'Languages',
                  style: TextStyle(color: AppColors.font_black, fontWeight: FontWeight.w600),
                ),
                backgroundColor: AppColors.white,
                iconTheme: IconThemeData(
                  color: AppColors.font_black, //change your color here
                ),
              ),
              body: SettingsList(
                lightTheme: const SettingsThemeData(settingsListBackground: AppColors.white),
                sections: [
                  SettingsSection(
                      tiles: languages
                          .map((e) => SettingsTile(
                                title: Text(e["name"]!),
                                trailing: trailingWidget(lang.toString() == e["code"]),
                                onPressed: (BuildContext context) {
                                  changeLanguage(Locale(e["code"]!));
                                },
                              ))
                          .toList()),
                ],
              ),
            );
          });
        });
  }
}
