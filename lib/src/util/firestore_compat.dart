/// Tour documents should store `createdBy` as a Firebase Auth uid string; legacy or mistyped
/// Firestore data may use other types (for example Timestamp), which must not be passed where a String is required.
String tourCreatedByAsString(dynamic raw) {
  if (raw is String) return raw;
  return '';
}

/// Firestore fields like `title`, `description`, `audio`: map `{ "en": "...", "es": "..." }`.
/// Returns [locale] if present, else [fallbackLocale], else first non-empty value. Never throws if [field] is null.
String localizedFirestoreString(dynamic field, String locale, {String fallbackLocale = 'en'}) {
  if (field == null) return '';
  if (field is String) return field;
  if (field is! Map) return field.toString();
  final m = Map<String, dynamic>.from(field);
  for (final key in <String>[locale, fallbackLocale]) {
    final v = m[key];
    if (v != null && v.toString().isNotEmpty) return v.toString();
  }
  for (final v in m.values) {
    if (v != null && v.toString().isNotEmpty) return v.toString();
  }
  return '';
}
