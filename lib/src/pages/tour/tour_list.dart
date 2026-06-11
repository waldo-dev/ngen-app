import 'dart:ui';

import 'package:app/src/pages/tour/simple_tour_card.dart';
import 'package:app/src/pages/tour/tour_card.dart';
import 'package:flutter/material.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/core/storage/localstorage_compat.dart';
import 'package:app/src/util/firestore_compat.dart';

class TourListWidget extends StatefulWidget {
  final List<Map<String, dynamic>> tourList;
  final bool dense;
  final bool offline;

  TourListWidget(this.tourList, [this.dense = false, this.offline = false]);

  @override
  State<TourListWidget> createState() => TourListWidgetState();
}

class TourListWidgetState extends State<TourListWidget> {
  final LocalStorage storage = new LocalStorage('ngen_app');
  late List<SimpleTourCard> imageSliders;
  int selectedTour = 0;
  late TourCard expandedCard;
  late List<TourCard> expandedCards;

  @override
  void initState() {
    super.initState();

    String locale = getLanguageCodeAmazon(storage.getItem('locale') ?? 'en') ?? 'en';

    imageSliders = widget.tourList
        .map((item) => SimpleTourCard(
            item['id'], item['image'], localizedFirestoreString(item['title'], locale), item['categories'], item['tier'], item['likeUsers'] ?? {}, widget.offline))
        .toList();
    expandedCard = TourCard(
        widget.tourList[0]['image'],
        localizedFirestoreString(widget.tourList[0]['title'], locale),
        localizedFirestoreString(widget.tourList[0]['description'], locale),
        widget.tourList[0]['categories'],
        widget.tourList[0]['tier'],
        widget.tourList[0]['id'],
        tourCreatedByAsString(widget.tourList[0]['createdBy']),
        widget.tourList[0]['likeUsers'] ?? {},
        widget.offline,
        tourPriceFromDoc(widget.tourList[0]),
        tourCurrencyFromDoc(widget.tourList[0]),
        tourIsPresentationFromDoc(widget.tourList[0]));

    expandedCards = widget.tourList
        .map((item) => TourCard(
            item['image'],
            localizedFirestoreString(item['title'], locale),
            localizedFirestoreString(item['description'], locale),
            item['categories'],
            item['tier'],
            item['id'],
            tourCreatedByAsString(item['createdBy']),
            item['likeUsers'] ?? {},
            widget.offline,
            tourPriceFromDoc(item),
            tourCurrencyFromDoc(item),
            tourIsPresentationFromDoc(item)))
        .toList();
  }

  getLanguageCodeAmazon(String locale) {
    if (locale == 'zh')
      return 'cmn';
    else if (locale == 'ar')
      return 'arb';
    else
      return locale;
  }

  Future<void> _showTour(int index) async {
    return showDialog<void>(
      barrierColor: Colors.white.withOpacity(0),
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return new BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Dialog(
              elevation: 0,
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.all(10),
              child: TourCard(
                  widget.tourList[index]['image'],
                  localizedFirestoreString(widget.tourList[index]['title'], getLanguageCodeAmazon(storage.getItem('locale') ?? 'en')),
                  localizedFirestoreString(widget.tourList[index]['description'], getLanguageCodeAmazon(storage.getItem('locale') ?? 'en')),
                  widget.tourList[index]['categories'],
                  widget.tourList[index]['tier'],
                  widget.tourList[index]['id'],
                  tourCreatedByAsString(widget.tourList[index]['createdBy']),
                  widget.tourList[index]['likeUsers'] ?? {},
                  widget.offline,
                  tourPriceFromDoc(widget.tourList[index]),
                  tourCurrencyFromDoc(widget.tourList[index]),
                  tourIsPresentationFromDoc(widget.tourList[index])),
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: imageSliders.length,
        itemBuilder: (context, index) {
          return Container(
              height: 200,
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              child: GestureDetector(
                  child: imageSliders[index],
                  onTap: () {
                    _showTour(index);
                  }));
        },
      )
    ]);
  }
}

