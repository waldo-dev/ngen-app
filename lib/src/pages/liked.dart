import 'package:app/src/pages/tour/tour_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app/l10n/app_localizations.dart';

class LikedWidget extends StatefulWidget {
  final List<String> selectedCategories;

  LikedWidget(this.selectedCategories);
  @override
  _LikedWidgetState createState() => _LikedWidgetState();
}

class _LikedWidgetState extends State<LikedWidget> {
  FirebaseAuth auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getLikedTours() {
    CollectionReference tours = FirebaseFirestore.instance.collection('tours');
    if (widget.selectedCategories.isNotEmpty) {
      return tours
          .doc('cl')
          .collection('list')
          .where("likeUsers.${auth.currentUser!.uid}", isEqualTo: true)
          .where("categories", arrayContainsAny: widget.selectedCategories)
          .limit(10)
          .get();
    } else {
      return tours.doc('cl').collection('list').where("likeUsers.${auth.currentUser!.uid}", isEqualTo: true).limit(10).get();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
          future: getLikedTours(),
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.hasError) {
              return Text("Something went wrong");
            }

            if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
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

            if (snapshot.connectionState == ConnectionState.done) {
              List<Map<String, dynamic>> data = snapshot.data!.docs.map((e) {
                Map<String, dynamic> tour = e.data();
                tour['id'] = e.id;
                return tour;
              }).toList();
              return TourListWidget(data);
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
        // TourCarouselWidget(tourList3)
      ],
    );
  }
}

