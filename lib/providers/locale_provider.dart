import 'package:flutter/material.dart';

class LocaleProvider with ChangeNotifier {
  Locale? _locale;
  Locale? get locale => _locale;
  List<String> locales = ['es', 'en', 'ar', 'zh', 'da', 'de', 'fr', 'is', 'it', 'ja', 'ko', 'nb', 'nl', 'pl', 'pt', 'ro', 'ru', 'sv', 'tr'];

  void setLocale(Locale locale) {
    if (!locales.contains(locale.toString())) return;
    _locale = locale;
    notifyListeners();
  }
}
