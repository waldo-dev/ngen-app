import 'package:app/core/locale/supported_app_locales.dart';
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
  final LocalStorage storage = LocalStorage('ngen_app');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: storage.ready,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.data == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Consumer<LocaleProvider>(builder: (context, provider, snapshot) {
            Widget trailingWidget(bool selectedLang) {
              return selectedLang ? const Icon(Icons.check, color: AppColors.primary) : const SizedBox.shrink();
            }

            void changeLanguage(Locale locale) {
              provider.setLocale(locale);
              storage.setItem('locale', locale.languageCode);
            }

            final lang = provider.locale ?? Localizations.localeOf(context);
            return Scaffold(
              appBar: AppBar(
                elevation: 1,
                title: const Text(
                  'Idioma',
                  style: TextStyle(color: AppColors.font_black, fontWeight: FontWeight.w600),
                ),
                backgroundColor: AppColors.white,
                iconTheme: const IconThemeData(
                  color: AppColors.font_black,
                ),
              ),
              body: SettingsList(
                lightTheme: const SettingsThemeData(settingsListBackground: AppColors.white),
                sections: [
                  SettingsSection(
                      tiles: SupportedAppLocales.options
                          .map((e) => SettingsTile(
                                title: Text(e['name']!),
                                trailing: trailingWidget(lang.languageCode == e['code']),
                                onPressed: (BuildContext context) {
                                  changeLanguage(Locale(e['code']!));
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
