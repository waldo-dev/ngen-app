import 'package:flutter/material.dart';

/// Idiomas de interfaz disponibles en la app (el turista elige; el QR no lleva idioma).
class SupportedAppLocales {
  static const List<String> codes = ['es', 'en', 'pt', 'de', 'fr'];

  static const List<Map<String, String>> options = [
    {'code': 'es', 'name': 'Español'},
    {'code': 'en', 'name': 'English'},
    {'code': 'pt', 'name': 'Português'},
    {'code': 'de', 'name': 'Deutsch'},
    {'code': 'fr', 'name': 'Français'},
  ];

  static List<Locale> get materialLocales =>
      codes.map((code) => Locale(code)).toList();

  static bool isSupported(String? code) {
    if (code == null || code.isEmpty) return false;
    return codes.contains(code.split('_').first);
  }

  static Locale normalize(String? code) {
    final lang = code?.split('_').first ?? 'es';
    return Locale(isSupported(lang) ? lang : 'es');
  }
}
