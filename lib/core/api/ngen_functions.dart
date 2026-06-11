import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'ngen_functions_exception.dart';

/// Callable wrappers for NGen backend (`ngen-495404`, `us-central1`).
///
/// Tourist flows: map, presentation, QR, purchase, step access, on-demand translation.
/// Operator/admin callables live here for reuse; primary UI is expected on webapp.
///
/// See [docs/BACKEND_API.md].
class NgenFunctions {
  NgenFunctions({
    FirebaseFunctions? functions,
    FirebaseAuth? auth,
    this.defaultCountryId = 'cl',
  })  : _functions = functions ??
            FirebaseFunctions.instanceFor(region: 'us-central1'),
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;
  final String defaultCountryId;

  // --- Tourist ---

  Future<List<Map<String, dynamic>>> listMapTours({String? countryId}) async {
    final data = await _call('listMapTours', {
      'countryId': countryId ?? defaultCountryId,
    });
    return _listOfMaps(data['tours'] ?? data['items'] ?? data);
  }

  Future<Map<String, dynamic>> startPresentationAccess({
    required String tourId,
    String? countryId,
  }) async {
    return _call('startPresentationAccess', {
      'countryId': countryId ?? defaultCountryId,
      'tourId': tourId,
    });
  }

  Future<Map<String, dynamic>> resolveTourQr({required String qrSlug}) async {
    return _call('resolveTourQr', {'qrSlug': qrSlug});
  }

  Future<Map<String, dynamic>> startTourFromQr({
    required String qrSlug,
    String? countryId,
    String? tourId,
  }) async {
    return _call('startTourFromQr', {
      if (qrSlug.isNotEmpty) 'qrSlug': qrSlug,
      if (countryId != null) 'countryId': countryId,
      if (tourId != null) 'tourId': tourId,
    });
  }

  Future<Map<String, dynamic>> unlockTourPurchase({
    required String tourId,
    required String paymentId,
    required num amount,
    required String currency,
    String? countryId,
  }) async {
    return _call('unlockTourPurchase', {
      'countryId': countryId ?? defaultCountryId,
      'tourId': tourId,
      'paymentId': paymentId,
      'amount': amount,
      'currency': currency,
    });
  }

  Future<TourAccessResult> checkTourAccess({
    required String tourId,
    String? stepId,
    String? lang,
    String? countryId,
  }) async {
    final data = await _call('checkTourAccess', {
      'countryId': countryId ?? defaultCountryId,
      'tourId': tourId,
      if (stepId != null) 'stepId': stepId,
      if (lang != null) 'lang': lang,
    });
    return TourAccessResult.fromMap(data);
  }

  Future<Map<String, dynamic>> ensureStepTranslation({
    required String tourId,
    required String stepId,
    required String lang,
    String? countryId,
  }) async {
    return _call('ensureStepTranslation', {
      'countryId': countryId ?? defaultCountryId,
      'tourId': tourId,
      'stepId': stepId,
      'lang': lang,
    });
  }

  // --- Operator (webapp; included for shared package / future app screens) ---

  Future<Map<String, dynamic>> updateTourSettings(Map<String, dynamic> payload) async {
    return _call('updateTourSettings', payload);
  }

  Future<Map<String, dynamic>> registerStepAudio(Map<String, dynamic> payload) async {
    return _call('registerStepAudio', payload);
  }

  Future<Map<String, dynamic>> translateTourStep(Map<String, dynamic> payload) async {
    return _call('translateTourStep', payload);
  }

  Future<Map<String, dynamic>> assignTourQr({
    required String tourId,
    String? countryId,
  }) async {
    return _call('assignTourQr', {
      'countryId': countryId ?? defaultCountryId,
      'tourId': tourId,
    });
  }

  Future<Map<String, dynamic>> getMyCredits() => _call('getMyCredits', {});

  Future<List<Map<String, dynamic>>> listMyCreditMovements({int? limit}) async {
    final data = await _call('listMyCreditMovements', {
      if (limit != null) 'limit': limit,
    });
    return _listOfMaps(data['movements'] ?? data['items'] ?? data);
  }

  Future<Map<String, dynamic>> getOperatorWallet() => _call('getOperatorWallet', {});

  Future<List<Map<String, dynamic>>> listWalletMovements({int? limit}) async {
    final data = await _call('listWalletMovements', {
      if (limit != null) 'limit': limit,
    });
    return _listOfMaps(data['movements'] ?? data['items'] ?? data);
  }

  /// Refreshes ID token after admin changes custom claims (`role`).
  Future<void> refreshAuthClaims() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.getIdToken(true);
    }
  }

  Future<Map<String, dynamic>> _call(String name, Map<String, dynamic> payload) async {
    try {
      final result = await _functions.httpsCallable(name).call(payload);
      return _normalizeResponse(result.data);
    } on FirebaseFunctionsException catch (e) {
      throw NgenFunctionsException.fromFirebase(e);
    }
  }

  static Map<String, dynamic> _normalizeResponse(dynamic data) {
    if (data == null) return {};
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    throw NgenFunctionsException('Unexpected callable response type: ${data.runtimeType}');
  }

  static List<Map<String, dynamic>> _listOfMaps(dynamic raw) {
    if (raw is! List) return [];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}

/// Parsed `checkTourAccess` response.
class TourAccessResult {
  TourAccessResult({
    required this.allowed,
    this.reason,
    this.needsTranslation = false,
    this.expiresAt,
    this.extra = const {},
  });

  final bool allowed;
  final String? reason;
  final bool needsTranslation;
  final DateTime? expiresAt;
  final Map<String, dynamic> extra;

  bool get isExpired => reason == 'expired';

  factory TourAccessResult.fromMap(Map<String, dynamic> map) {
    DateTime? expiresAt;
    final raw = map['expiresAt'];
    if (raw is String) {
      expiresAt = DateTime.tryParse(raw);
    } else if (raw != null) {
      // Firestore Timestamp serialized from callable may be {_seconds, _nanoseconds}
      final seconds = map['expiresAtSeconds'] ?? (raw is Map ? raw['_seconds'] : null);
      if (seconds is int) {
        expiresAt = DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true).toLocal();
      }
    }

    return TourAccessResult(
      allowed: map['allowed'] == true,
      reason: map['reason'] as String?,
      needsTranslation: map['needsTranslation'] == true,
      expiresAt: expiresAt,
      extra: Map<String, dynamic>.from(map),
    );
  }
}
