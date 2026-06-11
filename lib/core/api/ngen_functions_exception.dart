import 'package:cloud_functions/cloud_functions.dart';

/// Error from a callable Cloud Function (`FirebaseFunctionsException` or unexpected payload).
class NgenFunctionsException implements Exception {
  NgenFunctionsException(this.message, {this.code, this.details});

  final String message;
  final String? code;
  final dynamic details;

  factory NgenFunctionsException.fromFirebase(FirebaseFunctionsException e) {
    return NgenFunctionsException(
      e.message ?? e.code,
      code: e.code,
      details: e.details,
    );
  }

  @override
  String toString() => 'NgenFunctionsException($code): $message';
}
