import 'package:app/src/pages/tour/tour_card.dart';
import 'package:app/src/util/firestore_compat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Abre un tour desbloqueado por QR (sin paso de pago en la app).
class QrTourDetailPage extends StatelessWidget {
  const QrTourDetailPage({
    super.key,
    required this.tourId,
    this.countryId = 'cl',
  });

  final String tourId;
  final String countryId;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tour'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('tours')
            .doc(countryId)
            .collection('list')
            .doc(tourId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Tour no encontrado'));
          }

          final data = snapshot.data!.data() ?? {};
          return SingleChildScrollView(
            child: TourCard(
              data['image']?.toString() ?? '',
              localizedFirestoreString(data['title'], locale),
              localizedFirestoreString(data['description'], locale),
              data['categories'] is List ? data['categories'] as List : <dynamic>[],
              (data['tier'] as num?)?.toInt() ?? 0,
              tourId,
              data['managerId']?.toString() ?? data['operatorId']?.toString() ?? '',
              data['likeUsers'] is Map ? Map<String, dynamic>.from(data['likeUsers'] as Map) : {},
              false,
              tourPriceFromDoc(data),
              tourCurrencyFromDoc(data),
              tourIsPresentationFromDoc(data),
            ),
          );
        },
      ),
    );
  }
}
