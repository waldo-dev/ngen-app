import 'dart:io';
import 'dart:ui';

import 'package:app/src/pages/chat/chat.dart';
import 'package:app/src/pages/tour/download_tour.dart';
import 'package:app/src/pages/tour/recommendations.dart';
import 'package:app/src/pages/tour/steps/tour_steps.dart';
import 'package:app/src/util/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:app/l10n/app_localizations.dart';

class TourCard extends StatefulWidget {
  final String imgPath;
  final String title;
  final String description;
  final List<dynamic> categories;
  final int tier;
  final String tourId;
  final String managerId;
  final Map<String, dynamic> likeUsers;
  final bool offline;

  TourCard(this.imgPath, this.title, this.description, this.categories, this.tier, this.tourId, this.managerId, this.likeUsers,
      [this.offline = false]);

  @override
  State<TourCard> createState() => TourCardState();
}

class TourCardState extends State<TourCard> {
  CollectionReference steps = FirebaseFirestore.instance.collection('steps');

  bool toggleLike = false;
  bool liked = false;
  bool downloading = false;

  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  void likeThisTour() async {
    DocumentReference tourReference = FirebaseFirestore.instance.collection('tours').doc('cl').collection('list').doc(widget.tourId);
    setState(() {
      toggleLike = true;
    });

    FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get the document
      DocumentSnapshot snapshot = await transaction.get(tourReference);

      if (!snapshot.exists) {
        throw Exception("Tour does not exist!");
      }

      Map<String, dynamic> users = snapshot.data().toString().contains('likeUsers') ? snapshot.get("likeUsers") : {};

      if (users.isEmpty) {
        users[auth.currentUser!.uid] = true;
        // Perform an update on the document
        transaction.set(
          tourReference,
          {'likeUsers': users},
          SetOptions(merge: true),
        );
      } else {
        if (!users.containsKey(auth.currentUser!.uid)) {
          users[auth.currentUser!.uid] = true;
        }
        // Perform an update on the document
        transaction.update(tourReference, {'likeUsers': users});
      }

      // Return the new count
      return users;
    }).then((value) {
      setState(() {
        toggleLike = false;
        liked = true;
      });
      print("Users that liked this tour $value");
    }).catchError((error) {
      setState(() {
        toggleLike = false;
      });
      print("Failed to update users: $error");
    });
  }

  void unlikeThisTour() async {
    DocumentReference tourReference = FirebaseFirestore.instance.collection('tours').doc('cl').collection('list').doc(widget.tourId);
    setState(() {
      toggleLike = true;
    });

    FirebaseFirestore.instance.runTransaction((transaction) async {
      // Get the document
      DocumentSnapshot snapshot = await transaction.get(tourReference);

      if (!snapshot.exists) {
        throw Exception("Tour does not exist!");
      }

      Map<String, dynamic> users = snapshot.data().toString().contains('likeUsers') ? snapshot.get("likeUsers") : {};

      if (!users.isEmpty) {
        if (users.containsKey(auth.currentUser!.uid)) {
          users.remove(auth.currentUser!.uid);
        }
        // Perform an update on the document
        transaction.update(tourReference, {'likeUsers': users});
      }

      // Return the new count
      return users;
    }).then((value) {
      setState(() {
        toggleLike = false;
        liked = false;
      });
      print("Users that liked this tour $value");
    }).catchError((error) {
      setState(() {
        toggleLike = false;
      });
      print("Failed to update users: $error");
    });
  }

  Future<void> _showChat() async {
    // checkChat();
    return showDialog<void>(
      barrierColor: Colors.white.withOpacity(0),
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          elevation: 0,
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(10),
          child: ChatWidget(widget.tourId, widget.managerId),
        );
      },
    );
  }

  String getLocalizedCategories(String category) {
    switch (category) {
      case "hotel":
        return AppLocalizations.of(context)!.categoryHotel;
      case "restaurant":
        return AppLocalizations.of(context)!.categoryRestaurant;
      case "activities":
        return AppLocalizations.of(context)!.categoryActivities;
      case "park":
        return AppLocalizations.of(context)!.categoryPark;
      case "night_activities":
        return AppLocalizations.of(context)!.categoryNightActivities;
      case "church":
        return AppLocalizations.of(context)!.categoryChurch;
      case "museums":
        return AppLocalizations.of(context)!.categoryMuseums;
      default:
        return AppLocalizations.of(context)!.categoryHotel;
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider _image;
    if (widget.offline) {
      _image = FileImage(File(widget.imgPath));
    } else {
      _image = NetworkImage(
        widget.imgPath,
      );
    }
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Stack(children: <Widget>[
          Container(
            color: Colors.transparent,
            // margin: EdgeInsets.all(5.0),
            child: new SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                      color: Colors.transparent,
                      // margin: EdgeInsets.all(5.0),
                      child: Stack(children: <Widget>[
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                              image: DecorationImage(
                                image: _image,
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
                                colors: [
                                  Color.fromARGB(80, AppColors.primary.red, AppColors.primary.green, AppColors.primary.blue),
                                  Colors.transparent
                                ],
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
                        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                          Container(
                              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(left: 0),
                                    color: Colors.transparent,
                                    child: new IconButton(
                                        icon: new Icon(
                                          MdiIcons.arrowLeft,
                                          color: Colors.white,
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        }),
                                  ),
                                  Expanded(
                                    flex: 9,
                                    child: Text(
                                      widget.title,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                          Container(
                            height: 75,
                            color: Colors.transparent,
                            margin: EdgeInsets.symmetric(horizontal: 20.0),
                            child: SingleChildScrollView(
                                child: Text(
                              widget.description,
                              style: TextStyle(
                                color: AppColors.white,
                                shadows: <Shadow>[
                                  Shadow(
                                    offset: Offset(1.0, 1.0),
                                    blurRadius: 2.0,
                                    color: Color.fromARGB(200, 0, 0, 0),
                                  ),
                                ],
                              ),
                            )),
                          ),
                          Container(
                            color: Colors.transparent,
                            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Container(
                                padding: EdgeInsets.only(top: 3.0),
                                child: Row(
                                  children: <Widget>[
                                    Wrap(
                                      spacing: 5.0,
                                      runSpacing: 0.0,
                                      children: List<Widget>.generate(widget.categories.length,
                                          // place the length of the array here
                                          (int index) {
                                        return Container(
                                            decoration: BoxDecoration(
                                              color: AppColors.primary,
                                              borderRadius: BorderRadius.circular(
                                                4,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Color(
                                                    0x3f000000,
                                                  ),
                                                  offset: Offset(
                                                    0,
                                                    4,
                                                  ),
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                            child: Container(
                                                margin: EdgeInsets.all(5.0),
                                                child: Text(
                                                  getLocalizedCategories(widget.categories[index]),
                                                  style: TextStyle(color: AppColors.white),
                                                )));
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ])
                      ])),
                  SizedBox(
                    height: 10,
                  ),
                  TourStepsWidget(widget.tourId, widget.imgPath, widget.offline),
                  SizedBox(
                    height: 10,
                  ),
                  Visibility(visible: !widget.offline, child: RecommendationWidget(widget.tourId))
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 0,
            child: Column(children: [
              Visibility(
                visible: !widget.offline,
                child: Container(
                    width: 50,
                    padding: EdgeInsets.zero,
                    child: MaterialButton(
                      onPressed: () {
                        Share.share(
                            '${AppLocalizations.of(context)!.shareInitialText} ${widget.title}! ${AppLocalizations.of(context)!.shareSecondPartText} https://ngentours.com/',
                            subject: 'NgenApp');
                      },
                      elevation: 4,
                      splashColor: AppColors.primary,
                      color: Colors.white,
                      textColor: Colors.white,
                      child: Icon(
                        MdiIcons.shareVariant,
                        color: AppColors.primary,
                        size: 30,
                      ),
                      padding: EdgeInsets.all(8),
                      shape: CircleBorder(),
                    )),
              ),
              SizedBox(
                height: 10,
              ),
              DownloadTourWidget(widget.tourId, widget.imgPath),
              SizedBox(
                height: 10,
              ),
              Visibility(
                visible: !widget.offline,
                child: Container(
                    width: 50,
                    padding: EdgeInsets.zero,
                    child: MaterialButton(
                      onPressed: () {
                        if (liked) {
                          this.unlikeThisTour();
                        } else {
                          this.likeThisTour();
                        }
                      },
                      elevation: 4,
                      splashColor: AppColors.primary,
                      color: Colors.white,
                      textColor: Colors.white,
                      child: toggleLike
                          ? CircularProgressIndicator()
                          : Icon(
                              liked ? MdiIcons.heartOff : MdiIcons.heart,
                              color: AppColors.primary,
                              size: 30,
                            ),
                      padding: EdgeInsets.all(8),
                      shape: CircleBorder(),
                    )),
              ),
              SizedBox(
                height: 10,
              ),
              Visibility(
                visible: !widget.offline,
                child: Container(
                    width: 50,
                    padding: EdgeInsets.zero,
                    child: MaterialButton(
                      onPressed: () {
                        _showChat();
                      },
                      elevation: 4,
                      splashColor: AppColors.primary,
                      color: Colors.white,
                      textColor: Colors.white,
                      child: Icon(
                        MdiIcons.send,
                        color: AppColors.primary,
                        size: 30,
                      ),
                      padding: EdgeInsets.all(8),
                      shape: CircleBorder(),
                    )),
              )
            ]),
          ),
        ]));
  }
}

