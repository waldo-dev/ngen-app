import 'dart:io';

import 'package:app/src/pages/audio/audio.dart';
import 'package:app/src/util/colors.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:app/core/storage/localstorage_compat.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class StepsCarouselWidget extends StatefulWidget {
  final List<Map<String, dynamic>> steps;
  final String defaultImage;
  final bool offline;

  StepsCarouselWidget(this.steps, this.defaultImage, [this.offline = false]);

  @override
  State<StepsCarouselWidget> createState() => StepsCarouselWidgetState();
}

class StepsCarouselWidgetState extends State<StepsCarouselWidget> {
  int _current = 0;
  final LocalStorage storage = new LocalStorage('ngen_app');

  @override
  void initState() {
    super.initState();
  }

  getLanguageCodeAmazon(String locale) {
    if (locale == 'zh')
      return 'cmn';
    else if (locale == 'ar')
      return 'arb';
    else
      return locale;
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider _imageProvider;
    if (widget.offline) {
      _imageProvider = FileImage(File(
        widget.steps[_current]['image'],
      ));
    } else {
      _imageProvider = NetworkImage(
        widget.steps[_current]['image'] ?? "",
      );
    }
    return Container(
        color: Colors.transparent,
        // margin: EdgeInsets.all(5.0),
        child: Stack(children: <Widget>[
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.all(Radius.circular(15)),
                image: DecorationImage(
                  image: _imageProvider,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              padding: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                gradient: LinearGradient(
                  colors: [Color.fromARGB(80, AppColors.primary.red, AppColors.primary.green, AppColors.primary.blue), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.5, 1],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[],
              ),
            ),
          ),
          Column(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.steps
                    .asMap()
                    .map((i, e) => MapEntry(
                        i,
                        Container(
                          width: 10.0,
                          height: 10.0,
                          margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: _current == i ? Color.fromRGBO(255, 255, 255, 0.9) : Color.fromRGBO(255, 255, 255, 0.4)),
                        )))
                    .values
                    .toList()),
            CarouselSlider(
                options: CarouselOptions(
                    aspectRatio: 1.0,
                    viewportFraction: 1.0,
                    enlargeCenterPage: false,
                    onPageChanged: (int index, CarouselPageChangedReason reason) => {
                          setState(() {
                            _current = index;
                          })
                        }),
                items: widget.steps.map((e) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                          color: Colors.transparent,
                          // margin: EdgeInsets.all(5.0),
                          child: SingleChildScrollView(
                              child: Stack(children: <Widget>[
                            Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                                  child: Text(
                                    e['title'][getLanguageCodeAmazon(storage.getItem('locale') ?? 'en')] ?? '',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 120,
                                  color: Colors.transparent,
                                  margin: EdgeInsets.symmetric(horizontal: 20.0),
                                  child: SingleChildScrollView(
                                      child: Text(
                                    e['description'][getLanguageCodeAmazon(storage.getItem('locale') ?? 'en')] ?? '',
                                    style: TextStyle(color: AppColors.white),
                                  )),
                                ),
                                Container(
                                  child:
                                      Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                    Expanded(
                                      flex: 12,
                                      child: AudioWidget(
                                        e['audio'][getLanguageCodeAmazon(storage.getItem('locale') ?? 'en')] ?? '',
                                      ),
                                    ),
                                    // Expanded(
                                    //   flex: 2,
                                    //   child: Container(
                                    //       padding: EdgeInsets.only(right: 10, top: 15),
                                    //       child: MaterialButton(
                                    //         onPressed: () {},
                                    //         elevation: 0,
                                    //         splashColor: AppColors.primary,
                                    //         color: Colors.white,
                                    //         textColor: Colors.white,
                                    //         child: Icon(
                                    //           MdiIcons.mapMarkerRadius,
                                    //           color: AppColors.primary,
                                    //           size: 30,
                                    //         ),
                                    //         padding: EdgeInsets.all(8),
                                    //         shape: CircleBorder(),
                                    //       )),
                                    // ),
                                  ]),
                                ),
                              ],
                            )
                          ])));
                    },
                  );
                }).toList()),
          ])
        ]));
  }
}
