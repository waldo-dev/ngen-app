import 'package:cloud_firestore/cloud_firestore.dart';

/// Normalized map coordinates from Firestore `location` (Map or GeoPoint).
class TourLatLng {
  final double latitude;
  final double longitude;

  const TourLatLng(this.latitude, this.longitude);
}

/// Returns null if [location] is missing or cannot be parsed (legacy bad data).
TourLatLng? tourLocationFromFirestore(dynamic location) {
  if (location == null) return null;
  if (location is GeoPoint) {
    return TourLatLng(location.latitude, location.longitude);
  }
  if (location is Map) {
    final m = Map<String, dynamic>.from(location);
    final lat = m['latitude'] ?? m['lat'];
    final lng = m['longitude'] ?? m['lng'] ?? m['long'] ?? m['longitude '];
    if (lat is! num || lng is! num) return null;
    return TourLatLng(lat.toDouble(), lng.toDouble());
  }
  return null;
}

/// Tour documents should store `createdBy` as a Firebase Auth uid string; legacy or mistyped
/// Firestore data may use other types (for example Timestamp), which must not be passed where a String is required.
String tourCreatedByAsString(dynamic raw) {
  if (raw is String) return raw;
  return '';
}

int tourPriceFromDoc(Map<String, dynamic> data) {
  final raw = data['priceCents'] ?? data['price'];
  if (raw is num) return raw.toInt();
  return 0;
}

String tourCurrencyFromDoc(Map<String, dynamic> data) {
  final currency = data['currency'];
  return currency is String && currency.trim().isNotEmpty ? currency.trim() : 'CLP';
}

bool tourIsPresentationFromDoc(Map<String, dynamic> data) {
  return data['isPresentation'] == true;
}

/// Por defecto true (tours legacy sin campo).
bool tourShowOnMapFromDoc(Map<String, dynamic> data) {
  return data['showOnMap'] != false;
}

bool tourIsActiveCatalogEntry(Map<String, dynamic> data) {
  if (data['active'] != true) return false;
  final stepCount = data['stepCount'];
  if (stepCount is num && stepCount <= 0) return false;
  return true;
}

/// Tours con pin en mapa: publicados, visibles en mapa y con coordenadas válidas.
bool tourEligibleForMap(Map<String, dynamic> data) {
  if (!tourIsActiveCatalogEntry(data)) return false;
  if (!tourShowOnMapFromDoc(data)) return false;
  return tourLocationFromFirestore(data['location']) != null;
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
