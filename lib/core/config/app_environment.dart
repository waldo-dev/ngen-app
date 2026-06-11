import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint, defaultTargetPlatform, kDebugMode, kIsWeb, TargetPlatform;
import 'package:global_configuration/global_configuration.dart';

/// Runtime environment: local Firebase emulators vs production project.
enum NgenEnv {
  local,
  production,
}

/// Loads env from `--dart-define=NGEN_ENV=local|production` or [assets/cfg/settings.json].
///
/// Host for emulators: `--dart-define=NGEN_HOST=192.168.x.x` or `"host"` in settings.
/// Android emulator maps `localhost` / `127.0.0.1` → `10.0.2.2` (host PC).
/// Physical phone on USB/Wi‑Fi: set LAN IP of your PC (e.g. `192.168.100.9`).
class AppEnvironment {
  static NgenEnv env = NgenEnv.production;
  static String emulatorHost = '127.0.0.1';

  static bool get isLocal => env == NgenEnv.local;

  /// `--dart-define=NGEN_ENV=local|production` (empty = read settings.json).
  static const String _dartEnv = String.fromEnvironment('NGEN_ENV');

  /// `--dart-define=NGEN_HOST=192.168.x.x` overrides settings `"host"`.
  static const String _dartHost = String.fromEnvironment('NGEN_HOST');

  static Future<void> load() async {
    await GlobalConfiguration().loadFromAsset('settings');
    env = _resolveEnv();
    emulatorHost = _resolveEmulatorHost();
    if (kDebugMode) {
      debugPrint('[NGen] env=${env.name} emulatorHost=$emulatorHost');
    }
  }

  static NgenEnv _resolveEnv() {
    switch (_dartEnv) {
      case 'local':
      case 'development':
        return NgenEnv.local;
      case 'production':
      case 'prod':
        return NgenEnv.production;
      default:
        final mode = GlobalConfiguration().getValue('mode');
        if (mode == 'development') return NgenEnv.local;
        return NgenEnv.production;
    }
  }

  static String _resolveEmulatorHost() {
    final fromSettings = GlobalConfiguration().getValue('host');
    var host = _dartHost.isNotEmpty
        ? _dartHost
        : (fromSettings is String && fromSettings.isNotEmpty ? fromSettings : '127.0.0.1');
    return _hostForPlatform(host);
  }

  static String _hostForPlatform(String host) {
    if (kIsWeb) {
      return host == 'localhost' ? '127.0.0.1' : host;
    }
    if (defaultTargetPlatform == TargetPlatform.android &&
        (host == 'localhost' || host == '127.0.0.1')) {
      return '10.0.2.2';
    }
    return host;
  }

  /// Connect Auth, Firestore and Functions to local emulators (see backend README).
  static Future<void> connectFirebaseEmulators() async {
    if (!isLocal) return;

    final host = emulatorHost;
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    FirebaseFunctions.instanceFor(region: 'us-central1').useFunctionsEmulator(host, 5001);

    if (kDebugMode) {
      debugPrint('[NGen] emulators → Auth :9099 Firestore :8080 Functions :5001 @ $host');
    }
  }

  /// Local: optional `devEmail` / `devPassword` in settings (e.g. `operator@ngen.test`).
  /// Production: anonymous sign-in if no session.
  static Future<User?> ensureSignedIn() async {
    var user = FirebaseAuth.instance.currentUser;

    if (isLocal) {
      final email = GlobalConfiguration().getValue('devEmail');
      final password = GlobalConfiguration().getValue('devPassword');
      if (email is String &&
          email.isNotEmpty &&
          password is String &&
          password.isNotEmpty) {
        try {
          if (user?.email != email) {
            await FirebaseAuth.instance.signOut();
            user = null;
          }
          if (user == null) {
            final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: email,
              password: password,
            );
            user = cred.user;
          }
          await user?.getIdToken(true);
          if (kDebugMode) {
            debugPrint('[NGen] signed in as ${user?.email} (${user?.uid})');
          }
          return user;
        } catch (e) {
          debugPrint('[NGen] dev sign-in failed ($e); falling back to anonymous');
        }
      }
    }

    if (user == null) {
      final anonymous = await FirebaseAuth.instance.signInAnonymously();
      user = anonymous.user;
    }
    return user;
  }
}
