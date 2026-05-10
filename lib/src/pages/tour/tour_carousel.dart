import 'dart:ui';

import 'package:app/src/pages/tour/simple_tour_card.dart';
import 'package:app/src/pages/tour/tour_card.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:app/core/storage/localstorage_compat.dart';
import 'package:app/src/util/firestore_compat.dart';

class TourCarouselWidget extends StatefulWidget {
  final List<Map<String, dynamic>> tourList;
  final bool dense;
  final int active;
  final bool offline;

  TourCarouselWidget(this.tourList, [this.dense = false, this.active = 0, this.offline = false]);

  @override
  State<TourCarouselWidget> createState() => TourCarouselWidgetState();
}

class TourCarouselWidgetState extends State<TourCarouselWidget> {
  final CarouselSliderController _controller = CarouselSliderController();
  final LocalStorage storage = new LocalStorage('ngen_app');
  late List<SimpleTourCard> imageSliders;
  int selectedTour = 0;
  late TourCard expandedCard;
  late List<TourCard> expandedCards;

  @override
  void initState() {
    super.initState();

    _init();
  }

  @override
  void didUpdateWidget(TourCarouselWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.ready) {
      _controller.animateToPage(widget.active);
      selectedTour = widget.active;
      expandedCard = expandedCards[selectedTour];
    }
    _init();
  }

  getLanguageCodeAmazon(String locale) {
    if (locale == 'zh')
      return 'cmn';
    else if (locale == 'ar')
      return 'arb';
    else
      return locale;
  }

  void _init() {
    setState(() {
      selectedTour = widget.active;
    });
    final loc = getLanguageCodeAmazon(storage.getItem('locale') ?? 'en');
    imageSliders = widget.tourList
        .map((item) => SimpleTourCard(item['id'], item['image'] ?? '', localizedFirestoreString(item['title'], loc),
            item['categories'], item['tier'], item['likeUsers'] ?? {}, widget.offline))
        .toList();

    if (widget.tourList.isEmpty) {
    } else {
      expandedCard = TourCard(
          widget.tourList[0]['image'],
          localizedFirestoreString(widget.tourList[0]['title'], loc),
          localizedFirestoreString(widget.tourList[0]['description'], loc),
          widget.tourList[0]['categories'],
          widget.tourList[0]['tier'],
          widget.tourList[0]['id'],
          tourCreatedByAsString(widget.tourList[0]['createdBy']),
          widget.tourList[0]['likeUsers'] ?? {},
          widget.offline);
    }

    expandedCards = widget.tourList
        .map((item) => TourCard(
            item['image'] ?? '',
            localizedFirestoreString(item['title'], loc),
            localizedFirestoreString(item['description'], loc),
            item['categories'],
            item['tier'],
            item['id'],
            tourCreatedByAsString(item['createdBy']),
            item['likeUsers'] ?? {},
            widget.offline))
        .toList();
  }

  Future<void> _showTour() async {
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
              child: expandedCards[selectedTour],
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
      child: ScrollOnExpand(
        scrollOnExpand: true,
        scrollOnCollapse: true,
        child: CarouselSlider(
          carouselController: _controller,
          options: CarouselOptions(
              aspectRatio: widget.dense ? 3.0 : 2.0,
              enlargeCenterPage: true,
              enableInfiniteScroll: true,
              initialPage: widget.active,
              autoPlay: false,
              onPageChanged: (int index, CarouselPageChangedReason reason) => {
                    setState(() {
                      selectedTour = index;
                      expandedCard = expandedCards[index];
                    })
                  }),
          items: imageSliders.map((e) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    child: GestureDetector(
                        child: e,
                        onTap: () {
                          _showTour();
                        }));
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
