import 'package:app/src/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app/l10n/app_localizations.dart';

class RecommendationWidget extends StatefulWidget {
  final String tourId;
  RecommendationWidget(this.tourId);

  @override
  State<RecommendationWidget> createState() => RecommendationWidgetState();
}

class RecommendationWidgetState extends State<RecommendationWidget> {
  String description = "";
  double rating = 0;
  bool loading = false;
  FirebaseAuth auth = FirebaseAuth.instance;
  final commentaryController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Start listening to changes.
    commentaryController.addListener(() {
      setState(() {
        this.description = commentaryController.text;
      });
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    commentaryController.dispose();
    super.dispose();
  }

  void submitCommentary() async {
    CollectionReference comments =
        FirebaseFirestore.instance.collection('tours').doc('cl').collection('list').doc(widget.tourId).collection('comments');

    setState(() {
      loading = true;
    });

    await comments.add(
        {"userId": auth.currentUser!.uid, "userName": auth.currentUser!.displayName ?? "Anonymous", "description": description, "rating": rating});

    commentaryController.clear();
    setState(() {
      rating = 0;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        // margin: EdgeInsets.all(5.0),
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: AppColors.white),
        child: Stack(children: <Widget>[
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Card(
              elevation: 0,
              child: Container(
                // margin: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                    child: Column(
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 10, top: 10),
                                  child: Text(
                                    AppLocalizations.of(context)!.recommendations,
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 25.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [],
                            )
                          ],
                        ),
                        Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Card(
                                elevation: 0,
                                child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Column(children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                AppLocalizations.of(context)!.rateThisTour,
                                                style: TextStyle(
                                                  color: AppColors.font_bold,
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              RatingBar(
                                                ratingWidget: RatingWidget(
                                                  full: Icon(
                                                    MdiIcons.star,
                                                    color: AppColors.primary,
                                                  ),
                                                  half: Icon(
                                                    MdiIcons.starHalf,
                                                    color: AppColors.primary,
                                                  ),
                                                  empty: Icon(
                                                    MdiIcons.star,
                                                    color: AppColors.inactive,
                                                  ),
                                                ),
                                                initialRating: rating,
                                                itemSize: 25,
                                                direction: Axis.horizontal,
                                                itemCount: 5,
                                                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                                onRatingUpdate: (double rating) {
                                                  setState(() {
                                                    this.rating = rating;
                                                  });
                                                },
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Container(
                                                width: MediaQuery.of(context).size.width * 0.7,
                                                child: Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: TextField(
                                                        controller: commentaryController,
                                                        autofocus: false,
                                                        cursorColor: AppColors.primary,
                                                        maxLines: null,
                                                        onChanged: (text) {
                                                          setState(() {
                                                            description = text;
                                                          });
                                                        },
                                                        decoration: InputDecoration(
                                                            filled: true,
                                                            fillColor: AppColors.white,
                                                            focusedBorder: OutlineInputBorder(
                                                              borderSide: const BorderSide(color: AppColors.primary, width: 1.0),
                                                              borderRadius: BorderRadius.circular(10.0),
                                                            ),
                                                            enabledBorder: OutlineInputBorder(
                                                              borderSide: const BorderSide(color: AppColors.primary, width: 1.0),
                                                              borderRadius: BorderRadius.circular(10.0),
                                                            ),
                                                            labelText: AppLocalizations.of(context)!.describeYourExperience),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              SizedBox(
                                                  width: MediaQuery.of(context).size.width * 0.7,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      submitCommentary();
                                                    },
                                                    child: Text(AppLocalizations.of(context)!.submit),
                                                  )),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ])))),
                        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance
                              .collection('tours')
                              .doc('cl')
                              .collection('list')
                              .doc(widget.tourId)
                              .collection('comments')
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
                            return Column(children: <Widget>[
                              ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                      child: Card(
                                          elevation: 2,
                                          child: Padding(
                                              padding: EdgeInsets.all(10),
                                              child: Column(children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          data[index]['userName'],
                                                          style: TextStyle(
                                                            color: AppColors.font_bold,
                                                            fontSize: 16.0,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        RatingBarIndicator(
                                                          rating: data[index]['rating'],
                                                          itemSize: 25,
                                                          direction: Axis.horizontal,
                                                          itemCount: 5,
                                                          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                                          itemBuilder: (context, _) => Icon(
                                                            MdiIcons.star,
                                                            color: AppColors.primary,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    // Column(
                                                    //   children: [
                                                    //     Icon(
                                                    //       MdiIcons.heartOutline,
                                                    //       color: AppColors.primary,
                                                    //     ),
                                                    //     Text(
                                                    //       "90k",
                                                    //       style: TextStyle(
                                                    //         color: AppColors.primary,
                                                    //         fontSize: 16.0,
                                                    //         fontWeight: FontWeight.bold,
                                                    //       ),
                                                    //     ),
                                                    //   ],
                                                    // ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Column(
                                                  children: [
                                                    Text(
                                                      data[index]['description'],
                                                      style: TextStyle(
                                                        color: AppColors.font_light,
                                                        fontSize: 12.0,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ]))));
                                },
                              )
                            ]);
                          },
                        ),
                      ],
                    )),
              ),
            )
          ])
        ]));
  }
}

