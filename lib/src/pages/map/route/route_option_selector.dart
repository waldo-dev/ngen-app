import 'package:app/src/pages/tour/simple_tour_card.dart';
import 'package:app/src/util/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:app/core/storage/localstorage_compat.dart';
import 'package:app/src/util/globals.dart' as globals;

class RouteOptionSelector extends StatefulWidget {
  final String filter;
  final int position;

  const RouteOptionSelector(this.filter, this.position);

  @override
  State<RouteOptionSelector> createState() => RouteOptionSelectorState();
}

class RouteOptionSelectorState extends State<RouteOptionSelector> {
  late QuerySnapshot<Map<String, dynamic>> toursLoaded;
  late QuerySnapshot<Map<String, dynamic>> googleLoaded;
  List<Map<String, dynamic>> options = [];
  bool loaded = false;
  bool noToursWithFilter = false;
  List<bool> itemSelected = [true, false];

  Future<List<Map<String, dynamic>>> getTours() async {
    CollectionReference tours = FirebaseFirestore.instance.collection('tours');
    CollectionReference google = FirebaseFirestore.instance.collection('google');

    if (!loaded) {
      toursLoaded = await tours.doc('cl').collection('list').limit(10).where('categories', arrayContains: widget.filter).get();
      if (toursLoaded.size == 0) {
        toursLoaded = await tours.doc('cl').collection('list').limit(10).get();
      }
      googleLoaded = await google
          .doc('cl')
          .collection('list')
          .limit(10)
          .where('categories', arrayContains: widget.filter)
          .orderBy("rating", descending: true)
          .limit(5)
          .get();
      setState(() {
        loaded = true;
        noToursWithFilter = true;
      });
    }

    List<Map<String, dynamic>> ngen = toursLoaded.docs.map((e) {
      Map<String, dynamic> tour = e.data();
      tour['id'] = e.id;
      return tour;
    }).toList();
    List<Map<String, dynamic>> googleTours = googleLoaded.docs.map((e) {
      Map<String, dynamic> tour = e.data();
      tour['id'] = e.id;
      return tour;
    }).toList();

    if (globals.route[widget.position].keys.isEmpty) {
      globals.route[widget.position] = ngen[noToursWithFilter ? widget.position : 0];
    }
    options = [ngen[noToursWithFilter ? widget.position : 0], googleTours[0]];

    return options;
  }

  @override
  Widget build(BuildContext context) {
    return !loaded
        ? FutureBuilder<List<Map<String, dynamic>>>(
            future: getTours(),
            builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (snapshot.hasError) {
                return Text("Something went wrong");
              }

              if (snapshot.hasData && snapshot.data!.isEmpty) {
                return Text("Loading incorrect tours does not exist");
              }

              if (snapshot.connectionState == ConnectionState.done) {
                List<Map<String, dynamic>> data = snapshot.data!;
                return Column(children: <Widget>[
                  ListView.builder(
                      itemCount: 2,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return RouteItem(index, data, globals.route[widget.position]['id'] == data[index]['id'], () {
                          var selectedItem = [false, false];
                          selectedItem[index] = true;
                          setState(() {
                            itemSelected = selectedItem;
                          });
                        });
                      })
                ]);
              }

              return Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ));
            },
          )
        : Column(children: <Widget>[
            options.length > 0
                ? ListView.builder(
                    itemCount: 2,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      List<Map<String, dynamic>> data = options;
                      return RouteItem(index, data, globals.route[widget.position]['id'] == data[index]['id'], () {
                        var selectedItem = [false, false];
                        selectedItem[index] = true;
                        setState(() {
                          globals.route[widget.position] = data[index];
                          itemSelected = selectedItem;
                        });
                      });
                    })
                : Text('')
          ]);
    ;
  }
}

class RouteItem extends StatefulWidget {
  final int index;
  final List<Map<String, dynamic>> tourList;
  final bool selected;
  final VoidCallback callback;

  const RouteItem(this.index, this.tourList, this.selected, this.callback);

  @override
  _RouteItem createState() => new _RouteItem();
}

class _RouteItem extends State<RouteItem> {
  final LocalStorage storage = new LocalStorage('ngen_app');

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
    return new GestureDetector(
      onTap: () {
        widget.callback();
      },
      child: Container(
        height: 200,
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(horizontal: 5.0),
        child: SimpleTourCard(
            widget.tourList[widget.index]['id'],
            widget.tourList[widget.index]['image'] ??
                (widget.tourList[widget.index]["photoReference"] != ""
                    ? 'https://maps.googleapis.com/maps/api/place/photo?photoreference=${widget.tourList[widget.index]["photoReference"]}&sensor=false&maxheight=400&maxwidth=400&key=AIzaSyDZ3zUNueHCkw3jwMXfwIpam0NCJFKG1I4'
                    : "https://live.staticflickr.com/3769/11393976723_15eb9d48c7_b.jpg"),
            widget.tourList[widget.index]['title'] != null
                ? widget.tourList[widget.index]['title'][getLanguageCodeAmazon(storage.getItem('locale') ?? 'en')]
                : widget.tourList[widget.index]['name'],
            widget.tourList[widget.index]['categories'],
            widget.tourList[widget.index]['tier'] ?? 0,
            widget.tourList[widget.index]['likeUsers'] ?? {}),
        decoration: widget.selected
            ? new BoxDecoration(
                color: AppColors.primary,
                border: new Border.all(color: AppColors.primary, width: .1),
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
              )
            : new BoxDecoration(
                color: Colors.transparent,
                border: new Border.all(color: Colors.transparent, width: .1),
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
              ),
      ),
    );
  }
}
