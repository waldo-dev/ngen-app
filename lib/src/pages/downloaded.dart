import 'dart:convert';
import 'dart:io';

import 'package:app/src/pages/tour/tour_list.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:app/l10n/app_localizations.dart';

class DownloadedWidget extends StatefulWidget {
  @override
  _DownloadedWidgetState createState() => _DownloadedWidgetState();
}

class _DownloadedWidgetState extends State<DownloadedWidget> {
  @override
  void initState() {
    super.initState();
  }

  Future<List<Map<String, dynamic>>> getDownloadedTours() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();

    Directory dir = Directory(documentDirectory.path + '/tours');

    List<Map<String, dynamic>> downloadedTours = [];
    if (await dir.exists()) {
      var listOfAllFolderAndFiles = await dir.list(recursive: false).toList();
      List<Directory> toursDirectories = listOfAllFolderAndFiles.whereType<Directory>().toList();

      for (var i = 0; i < toursDirectories.length; i++) {
        File file = await File(toursDirectories[i].path + '/tourinfo.json');
        final contents = await file.readAsString();
        Map<String, dynamic> tour = jsonDecode(contents);
        // tour["image"] = "file:///" + e.path + '/tourimage';
        downloadedTours.add(tour);
      }
    }
    return downloadedTours;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<List<Map<String, dynamic>>>(
          future: getDownloadedTours(),
          builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            if (snapshot.hasError) {
              return Text('Something went wrong');
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasData && snapshot.data!.isEmpty) {
              return Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  height: 200,
                  child: Card(
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
                                    image: AssetImage("assets/images/santiago.jpg"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 70.0,
                              left: 0.0,
                              right: 0.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 12,
                                      child: Text(
                                        AppLocalizations.of(context)!.noTourFoundText,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )),
                  ));
            }

            return TourListWidget(snapshot.data!, false, true);
          },
        ),
        // TourCarouselWidget(tourList3)
      ],
    );
  }
}

