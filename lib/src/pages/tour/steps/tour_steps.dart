import 'dart:convert';
import 'dart:io';

import 'package:app/src/pages/tour/steps/steps_carousel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class TourStepsWidget extends StatefulWidget {
  final String tourId;
  final String imgPath;
  final bool offline;

  TourStepsWidget(this.tourId, this.imgPath, [this.offline = false]);

  @override
  State<TourStepsWidget> createState() => TourStepsWidgetState();
}

class TourStepsWidgetState extends State<TourStepsWidget> {
  bool loaded = false;
  late List<Map<String, dynamic>> stepList;

  @override
  void initState() {
    super.initState();
  }

  Future<List<Map<String, dynamic>>> getStepList() async {
    if (!loaded) {
      if (widget.offline) {
        Directory documentDirectory = await getApplicationDocumentsDirectory();

        Directory dir = Directory(documentDirectory.path + '/tours/${widget.tourId}');
        if (await dir.exists()) {
          File file = await File(dir.path + '/tourinfo.json');

          final contents = await file.readAsString();
          Map<String, dynamic> tour = jsonDecode(contents);

          setState(() {
            loaded = true;
          });

          stepList = List<Map<String, dynamic>>.from(tour['steps']);
          stepList.sort((a, b) => (a['position'] ?? 0).compareTo((b['position'] ?? 0)));
          stepList = stepList.where((element) => element['active'] != false).toList();
        }
      } else {
        QuerySnapshot stepSnap = await FirebaseFirestore.instance.collection('steps').doc(widget.tourId).collection('list').get();

        stepList = stepSnap.docs.map((QueryDocumentSnapshot e) {
          Map<String, dynamic> step = e.data() as Map<String, dynamic>;
          step['id'] = e.id;
          return step;
        }).toList();

        stepList.sort((a, b) => (a['position'] ?? 0).compareTo((b['position'] ?? 0)));
        stepList = stepList.where((element) => element['active'] != false).toList();

        print(widget.tourId);
      }
    }
    return stepList;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: getStepList(),
        builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          return StepsCarouselWidget(snapshot.data!, widget.imgPath, widget.offline);
        });
  }
}
