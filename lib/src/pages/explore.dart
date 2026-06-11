import 'dart:ui';

import 'package:app/core/theme/ngen_theme.dart';
import 'package:app/src/pages/tour/tour_carousel.dart';
import 'package:app/src/util/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:app/l10n/app_localizations.dart';

class ExploreWidget extends StatefulWidget {
  final List<String> selectedCategories;

  ExploreWidget(this.selectedCategories);
  @override
  _ExploreWidgetState createState() => _ExploreWidgetState();
}

class _ExploreWidgetState extends State<ExploreWidget> {
  @override
  void initState() {
    super.initState();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getHighTierTours() {
    CollectionReference tours = FirebaseFirestore.instance.collection('tours');
    if (widget.selectedCategories.isNotEmpty) {
      return tours
          .doc('cl')
          .collection('list')
          .where('tier', isEqualTo: 1)
          .where("categories", arrayContainsAny: widget.selectedCategories)
          .where('active', isEqualTo: true)
          .limit(10)
          .snapshots();
    } else {
      return tours.doc('cl').collection('list').where('tier', isEqualTo: 1).where('active', isEqualTo: true).limit(10).snapshots();
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getPublicTours() {
    CollectionReference tours = FirebaseFirestore.instance.collection('tours');
    if (widget.selectedCategories.isNotEmpty) {
      return tours
          .doc('cl')
          .collection('list')
          .where('tier', isEqualTo: 0)
          .where("categories", arrayContainsAny: widget.selectedCategories)
          .where('active', isEqualTo: true)
          .limit(10)
          .snapshots();
    } else {
      return tours.doc('cl').collection('list').where('tier', isEqualTo: 0).where('active', isEqualTo: true).limit(10).snapshots();
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getRestaurants() {
    CollectionReference tours = FirebaseFirestore.instance.collection('tours');
    if (widget.selectedCategories.isNotEmpty) {
      return tours
          .doc('cl')
          .collection('list')
          .where("categories", arrayContainsAny: [...widget.selectedCategories, 'restaurant'])
          .where('active', isEqualTo: true)
          .limit(10)
          .snapshots();
    } else {
      return tours.doc('cl').collection('list').where('categories', arrayContains: 'restaurant').where('active', isEqualTo: true).limit(10).snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    CollectionReference tours = FirebaseFirestore.instance.collection('tours');

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 12,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 48),
                child: Text(
                  AppLocalizations.of(context)!.subtitleRecommend,
                  style: NgenTheme.sectionHeader(context),
                ),
              ),
            ),
          ],
        ),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: getHighTierTours(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            List<Map<String, dynamic>> data = snapshot.data!.docs.map((e) {
              Map<String, dynamic> tour = e.data();
              tour['id'] = e.id;
              return tour;
            }).toList();
            return TourCarouselWidget(data);
          },
        ),
        Row(
          children: [
            Expanded(
              flex: 12,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 48),
                child: Text(
                  AppLocalizations.of(context)!.subtitlePopular,
                  style: NgenTheme.sectionHeader(context),
                ),
              ),
            ),
          ],
        ),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: getPublicTours(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            List<Map<String, dynamic>> data = snapshot.data!.docs.map((e) {
              Map<String, dynamic> tour = e.data();
              tour['id'] = e.id;
              return tour;
            }).toList();
            return TourCarouselWidget(data);
          },
        ),
        Row(
          children: [
            Expanded(
              flex: 12,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 48),
                child: Text(
                  AppLocalizations.of(context)!.subtitleRestaurants,
                  style: NgenTheme.sectionHeader(context),
                ),
              ),
            ),
          ],
        ),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: tours
              .doc('cl')
              .collection('list')
              .where('active', isEqualTo: true)
              .where('categories', arrayContains: 'restaurant')
              .limit(10)
              .snapshots(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            List<Map<String, dynamic>> data = snapshot.data!.docs.map((e) {
              Map<String, dynamic> tour = e.data();
              tour['id'] = e.id;
              return tour;
            }).toList();
            return TourCarouselWidget(data);
          },
        ),
        // TourCarouselWidget(tourList3)
      ],
    );
  }
}

