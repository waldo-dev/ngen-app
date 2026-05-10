import 'dart:io';

import 'package:app/src/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:app/l10n/app_localizations.dart';

class SimpleTourCard extends StatefulWidget {
  final String tourId;
  final String imgPath;
  final String title;
  final List<dynamic> categories;
  final int tier;
  final Map<String, dynamic> likeUsers;
  final bool offline;

  SimpleTourCard(this.tourId, this.imgPath, this.title, this.categories, this.tier, this.likeUsers, [this.offline = false]);

  @override
  State<SimpleTourCard> createState() => SimpleTourCardState();
}

class SimpleTourCardState extends State<SimpleTourCard> {
  FirebaseAuth auth = FirebaseAuth.instance;
  List<String> downloadedTourList = [];

  void toursDownloaded() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();

    Directory dir = Directory(documentDirectory.path + '/tours');

    if (await dir.exists()) {
      var listOfAllFolderAndFiles = await dir.list(recursive: false).toList();
      List<Directory> toursDirectories = listOfAllFolderAndFiles.whereType<Directory>().toList();

      if (toursDirectories.isNotEmpty) {
        if (mounted) {
          setState(() {
            downloadedTourList = toursDirectories.map((e) {
              List<String> pathSplitted = e.path.split("/");
              return pathSplitted[pathSplitted.length - 1];
            }).toList();
          });
        }
      }
    }
  }

  String getLocalizedCategories(String category) {
    if (AppLocalizations.of(context) == null) {
      return category;
    }
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
    toursDownloaded();
    ImageProvider _image;
    if (widget.offline) {
      _image = FileImage(File(widget.imgPath));
    } else {
      _image = NetworkImage(
        widget.imgPath,
      );
    }
    return Card(
      color: Colors.transparent,
      elevation: 0,
      // margin: EdgeInsets.all(5.0),
      child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: Container(
                  foregroundDecoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [Color.fromARGB(80, 114, 37, 215), Color.fromARGB(1, 114, 37, 215)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter)),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: _image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0.0,
                left: 0.0,
                right: 0.0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(15)),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 9,
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                          flex: 3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Visibility(
                                visible: downloadedTourList.contains(widget.tourId),
                                child: Icon(
                                  MdiIcons.downloadOutline,
                                  color: AppColors.white,
                                  size: 20,
                                ),
                              ),
                              Visibility(
                                visible: widget.tier > 0,
                                child: Icon(
                                  MdiIcons.send,
                                  color: AppColors.white,
                                  size: 20,
                                ),
                              ),
                              Visibility(
                                  visible: auth.currentUser != null && widget.likeUsers.containsKey(auth.currentUser!.uid),
                                  child: Icon(
                                    MdiIcons.heart,
                                    color: AppColors.white,
                                    size: 20,
                                  )),
                            ],
                          )),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0.0,
                left: 0.0,
                right: 0.0,
                child: Container(
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
              ),
            ],
          )),
    );
  }
}

