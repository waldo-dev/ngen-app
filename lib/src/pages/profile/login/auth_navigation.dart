import 'package:flutter/material.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';

/// Login / registro / recuperar contraseña van en el navigator raíz (pantalla completa).
/// Si se usa [Navigator.push] normal dentro de un tab, el segundo push (ej. registro) puede no verse.
Future<T?> pushAuthScreen<T>(BuildContext context, Widget screen) {
  return PersistentNavBarNavigator.pushNewScreen<T>(
    context,
    screen: screen,
    withNavBar: false,
    pageTransitionAnimation: PageTransitionAnimation.slideRight,
  );
}

void popAuthScreen(BuildContext context, [dynamic result]) {
  Navigator.of(context, rootNavigator: true).pop(result);
}

/// Cierra registro/login y vuelve al perfil tras crear cuenta o iniciar sesión.
void closeAuthFlow(BuildContext context, [dynamic result]) {
  final navigator = Navigator.of(context, rootNavigator: true);
  navigator.pop(result);
  if (navigator.canPop()) {
    navigator.pop(result);
  }
}
