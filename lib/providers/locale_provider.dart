import 'package:app/core/locale/supported_app_locales.dart';
import 'package:flutter/material.dart';

class LocaleProvider with ChangeNotifier {
  Locale? _locale;
  Locale? get locale => _locale;

  void hydrateFromStorage(String? storedCode) {
    _locale = SupportedAppLocales.normalize(storedCode);
  }

  void setLocale(Locale locale) {
    if (!SupportedAppLocales.isSupported(locale.languageCode)) return;
    _locale = Locale(locale.languageCode);
    notifyListeners();
  }
}
