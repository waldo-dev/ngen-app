import 'dart:ui';

import 'package:app/src/model/Category.dart';
import 'package:app/src/pages/downloaded.dart';
import 'package:app/src/pages/explore.dart';
import 'package:app/src/pages/liked.dart';
import 'package:app/src/templates/action_button.dart';
import 'package:app/src/templates/expandable_fab.dart';
import 'package:app/src/util/colors.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:flutter/material.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:app/src/util/globals.dart' as globals;

class SearchWidget extends StatefulWidget {
  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> with TickerProviderStateMixin {
  List<String> selectedCategories = [];
  String view = globals.offline? "downloaded": "explore";

  static var _categories = <Category>[];
  List<Category> options = _categories;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(SearchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    setCategoryItems();
  }

  void filterDataByCategory(List<String> values) async {
    setState(() {
      selectedCategories = values;
    });
  }

  Widget buildChild(widget_type) {
    if (widget_type == "explore") {
      return ExploreWidget(selectedCategories);
    } else if (widget_type == "liked") {
      return LikedWidget(selectedCategories);
    } else if (widget_type == "downloaded") {
      return DownloadedWidget();
    }
    return ExploreWidget(selectedCategories);
  }

  setCategoryItems() {
    var _categories = [
      Category(id: 1, name: AppLocalizations.of(context)!.categoryHotel, value: "hotel"),
      Category(id: 2, name: AppLocalizations.of(context)!.categoryRestaurant, value: "restaurant"),
      Category(id: 3, name: AppLocalizations.of(context)!.categoryActivities, value: "activities"),
      Category(id: 4, name: AppLocalizations.of(context)!.categoryPark, value: "park"),
      Category(id: 5, name: AppLocalizations.of(context)!.categoryNightActivities, value: "night_activities"),
      Category(id: 6, name: AppLocalizations.of(context)!.categoryChurch, value: "church"),
      Category(id: 7, name: AppLocalizations.of(context)!.categoryMuseums, value: "museums"),
    ];

    setState(() {
      options = _categories;
    });
  }

  @override
  Widget build(BuildContext context) {
    setCategoryItems();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Santiago',
          textAlign: TextAlign.center,
          style: TextStyle(
            shadows: <Shadow>[
              Shadow(
                offset: Offset(2.0, 2.0),
                blurRadius: 5.0,
                color: Color.fromARGB(180, 0, 0, 0),
              ),
            ],
            color: Colors.white,
            fontSize: 28.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Image(
          image: AssetImage("assets/images/santiago.jpg"),
          fit: BoxFit.cover,
        ),
        // backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: EdgeInsets.only(top: 0),
        child: Stack(children: [
          SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.only(top: 0),
                child: Column(
                  children: [
                    ChipsChoice<String>.multiple(
                      value: selectedCategories,
                      choiceStyle: C2ChoiceStyle(
                        labelStyle: TextStyle(color: AppColors.primary),
                        borderShape: RoundedRectangleBorder(
                            side: BorderSide(width: 1, color: AppColors.primary), borderRadius: BorderRadius.all(Radius.circular(4))),
                      ),
                      onChanged: (val) {
                        filterDataByCategory(val);
                      },
                      choiceItems: C2Choice.listFrom<String, Category>(
                        source: options,
                        value: (i, v) => v.value,
                        label: (i, v) => v.name,
                      ),
                    ),
                    // AnimatedSwitcher(
                    //   duration: const Duration(seconds: 1),
                    //   transitionBuilder: (Widget child, Animation<double> animation) {
                    //     const begin = Offset(2.0, 0.0);
                    //     const end = Offset.zero;
                    //     const curve = Curves.easeIn;

                    //     var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

                    //     return SlideTransition(
                    //       position: animation.drive(tween),
                    //       child: child,
                    //     );
                    //   },
                    //   child: buildChild(view),
                    // ),
                    buildChild(view)
                  ],
                )),
          ),
        ]),
      ),
      floatingActionButton: ExpandableFab(
        distance: 112.0,
        children: [
          ActionButton(
            onPressed: () {
              setState(() {
                view = "explore";
              });
            },
            icon: Icon(MdiIcons.magnify, color: AppColors.white),
          ),
          ActionButton(
            onPressed: () {
              setState(() {
                view = "downloaded";
              });
            },
            icon: Icon(
              MdiIcons.download,
              color: AppColors.white,
            ),
          ),
          ActionButton(
            onPressed: () {
              setState(() {
                view = "liked";
              });
            },
            icon: Icon(MdiIcons.heart, color: AppColors.white),
          ),
        ],
      ),
    );
  }
}

