import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:convert';

import 'package:app/src/model/Category.dart';
import 'package:app/src/pages/map/marker.dart';
import 'package:app/src/pages/map/google_marker.dart';
import 'package:app/src/pages/map/route/route_builder.dart';
import 'package:app/src/pages/map/step_marker.dart';
import 'package:app/src/pages/tour/tour_carousel.dart';
import 'package:app/src/templates/action_button.dart';
import 'package:app/src/util/colors.dart';
import 'package:app/src/values/constants.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:app/src/util/globals.dart' as globals;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:path_provider/path_provider.dart';
import 'package:app/core/storage/localstorage_compat.dart';

class MapWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  final LocalStorage storage = new LocalStorage('ngen_app');
  Completer<GoogleMapController> _controller = Completer();
  static var _categories = <Category>[];
  List<Category> options = _categories;
  bool loaded = false;
  FirebaseAuth auth = FirebaseAuth.instance;
  bool isAnonymous = true;
  late List<Map<String, dynamic>> toursLoaded;
  bool loading = false;
  int active = 0;
  int stepsTourId = 0;
  bool offline = false;

  // this will hold the generated polylines
  Set<Polyline> _polylines = {};

  // this will hold each polyline coordinate as Lat and Lng pairs
  List<LatLng> polylineCoordinates = [];

  List<NgenMarker> _markers = <NgenMarker>[];
  List<NgenStepMarker> _stepsMarkers = <NgenStepMarker>[];
  List<GoogleMarker> _gmarkers = <GoogleMarker>[];
  List<Marker> googleMarkers = [];
  List<String> selectedCategories = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setCategoryItems();
      checkAnonymous();
    });
    getMarkers();
    // _markers.add(NgenMarker('1', 'Teatro Caupolican', LatLng(-33.45630216806327, -70.64960770715045)));
    // _markers.add(NgenMarker('2', 'Metro Matta', LatLng(-33.45799338744311, -70.64322756520055)));
    // _markers.add(NgenMarker('3', 'Hospital San Borja', LatLng(-33.4591867, -70.6423168)));
  }

  getLanguageCodeAmazon(String locale) {
    if (locale == 'zh')
      return 'cmn';
    else if (locale == 'ar')
      return 'arb';
    else
      return locale;
  }

  void checkAnonymous() async {
    if (this.mounted) {
      setState(() {
        isAnonymous = auth.currentUser == null || auth.currentUser!.isAnonymous;
      });
    }
  }

  void filterDataByCategory(List<String> values) async {
    _stepsMarkers.clear();
    setState(() {
      active = 0;
      selectedCategories = values;
    });

    getMarkers();
  }

  Future<bool> online() async {
    globals.offline = true;
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        globals.offline = false;
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
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

  Future<List<Map<String, dynamic>>> getTours() async {
    QuerySnapshot<Map<String, dynamic>>? toursOnline;
    bool online = await this.online();
    if (online) {
      CollectionReference tours = FirebaseFirestore.instance.collection('tours');
      if (!loaded) {
        if (selectedCategories.isNotEmpty) {
          toursOnline = await tours
              .doc('cl')
              .collection('list')
              .where("categories", arrayContainsAny: selectedCategories)
              .where('active', isEqualTo: true)
              .get();
        } else {
          toursOnline = await tours.doc('cl').collection('list').where('active', isEqualTo: true).get();
        }
        setState(() {
          loaded = true;
        });
      }

      toursLoaded = toursOnline!.docs.map((e) {
        Map<String, dynamic> tour = e.data();
        tour['id'] = e.id;
        return tour;
      }).toList();
      return toursLoaded;
    }

    toursLoaded = await getDownloadedTours();
    return toursLoaded;
  }

  Future<List<Marker>> getMarkers() async {
    googleMarkers.clear();
    _markers.clear();
    _gmarkers.clear();
    bool online = await this.online();
    if (online) {
      QuerySnapshot<Map<String, dynamic>>? toursOnline;
      if (selectedCategories.isNotEmpty) {
        toursOnline = await FirebaseFirestore.instance
            .collection('tours')
            .doc('cl')
            .collection('list')
            .where("categories", arrayContainsAny: selectedCategories)
            .where('active', isEqualTo: true)
            .get();
      } else {
        toursOnline = await FirebaseFirestore.instance.collection('tours').doc('cl').collection('list').where('active', isEqualTo: true).get();
      }
      toursLoaded = toursOnline.docs.map((e) {
        Map<String, dynamic> tour = e.data();
        tour['id'] = e.id;
        return tour;
      }).toList();
    } else {
      toursLoaded = await getDownloadedTours();
    }
    // print("TOURS LOADED");
    // print(toursLoaded.size);
    for (var i = 0; i < toursLoaded.length; i++) {
      // print("Tour");
      // print(element.id);
      // print(toursLoaded.docs[i].data()['separatedSteps'] ?? false);
      var stepSeparate = toursLoaded[i]['separatedSteps'] ?? false;
      var tourId = toursLoaded[i]['id'];
      var index = i;
      var locale = getLanguageCodeAmazon(storage.getItem('locale') ?? 'en');
      _markers.add(
        NgenMarker(toursLoaded[i]['id'], toursLoaded[i]['title'][locale],
            LatLng(toursLoaded[i]['location']['latitude'] + .0, toursLoaded[i]['location']['longitude'] + .0), () async {
          if (stepSeparate) {
            if (offline) {
              var stepsLoaded = toursLoaded[i]['steps'];
              _stepsMarkers.clear();
              for (var j = 0; j < stepsLoaded.length; j++) {
                // print(j);
                _stepsMarkers.add(NgenStepMarker(stepsLoaded[j]['id'], stepsLoaded[j]['title'][locale],
                    LatLng(stepsLoaded[j]['location']['latitude'] + .0, stepsLoaded[j]['location']['longitude'] + .0), j, () {
                  setState(() {
                    active = index;
                  });
                }));
              }
            } else {
              var stepsLoaded = await FirebaseFirestore.instance.collection('steps').doc(tourId).collection('list').orderBy("position").get();
              _stepsMarkers.clear();
              for (var j = 0; j < stepsLoaded.docs.length; j++) {
                // print(j);
                _stepsMarkers.add(NgenStepMarker(stepsLoaded.docs[j].id, stepsLoaded.docs[j].get('title')[locale],
                    LatLng(stepsLoaded.docs[j].get('location')['latitude'] + .0, stepsLoaded.docs[j].get('location')['longitude'] + .0), j, () {
                  setState(() {
                    active = index;
                  });
                }));
              }
            }

            globals.nextStep = 0;
          }
          setState(() {
            active = i;
            stepsTourId = i;
          });

          if (stepSeparate) {
            getMarkers();
          }
        }),
      );
    }

    // // GET GOOGLE POINTS only if online
    // if (online) {
    //   var googlePointsLoaded;
    //   if (selectedCategories.isNotEmpty) {
    //     googlePointsLoaded = await FirebaseFirestore.instance
    //         .collection('google')
    //         .doc('cl')
    //         .collection('list')
    //         .where("categories", arrayContainsAny: selectedCategories)
    //         .limit(100)
    //         .get();
    //   } else {
    //     googlePointsLoaded = await FirebaseFirestore.instance.collection('google').doc('cl').collection('list').limit(100).get();
    //   }
    //   // print(googlePointsLoaded.docs.length);
    //   for (var i = 0; i < googlePointsLoaded.docs.length; i++) {
    //     if (googlePointsLoaded.docs[i].exists) {
    //       _gmarkers.add(
    //         GoogleMarker(
    //             googlePointsLoaded.docs[i].id,
    //             googlePointsLoaded.docs[i].get('name'),
    //             LatLng(googlePointsLoaded.docs[i].get('location')['latitude'] + .0, googlePointsLoaded.docs[i].get('location')['longitude'] + .0),
    //             () {}),
    //       );
    //     }
    //   }
    // }

    for (var i = 0; i < _markers.length; i++) {
      if (_stepsMarkers.isEmpty || stepsTourId != i) {
        var markerM = await _markers[i].getMarker();
        googleMarkers.add(markerM);
      }
    }

    // for (var marker in _gmarkers) {
    //   var markerM = await marker.getMarker();
    //   googleMarkers.add(markerM);
    // }

    for (var marker in _stepsMarkers) {
      var markerM = await marker.getMarker();
      googleMarkers.add(markerM);
    }

    setState(() {
      offline = !online;
    });
    // await Future.delayed(Duration(seconds: 1));
    return googleMarkers;
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

  void _currentLocation() async {
    final GoogleMapController controller = await _controller.future;
    LocationData currentLocation;
    var location = new Location();
    try {
      currentLocation = await location.getLocation();
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 0,
          target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
          zoom: 17.0,
        ),
      ));
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        String error = 'Permission denied';
        print(error);
      }
    }
  }

  void _routeNextStep() async {
    var firstStep = {'latitude': 0.0, 'longitude': 0.0};
    var secondStep = {'latitude': 0.0, 'longitude': 0.0};

    if (globals.nextStep == 0) {
      LocationData currentLocation;
      var location = new Location();
      try {
        currentLocation = await location.getLocation();

        firstStep = {
          'latitude': currentLocation.latitude!,
          'longitude': currentLocation.longitude!,
        };
      } on PlatformException catch (e) {
        if (e.code == 'PERMISSION_DENIED') {
          String error = 'Permission denied';
          print(error);
        }
      }

      secondStep = {
        'latitude': _stepsMarkers[globals.nextStep].getPosition().latitude,
        'longitude': _stepsMarkers[globals.nextStep].getPosition().longitude,
      };
    } else {
      firstStep = {
        'latitude': _stepsMarkers[globals.nextStep - 1].getPosition().latitude,
        'longitude': _stepsMarkers[globals.nextStep - 1].getPosition().longitude,
      };
      secondStep = {
        'latitude': _stepsMarkers[globals.nextStep].getPosition().latitude,
        'longitude': _stepsMarkers[globals.nextStep].getPosition().longitude,
      };
    }

    final polylinePoints = PolylinePoints();
    final polylineRequest = PolylineRequest(
      origin: PointLatLng(firstStep["latitude"]!, firstStep["longitude"]!),
      destination: PointLatLng(secondStep["latitude"]!, secondStep["longitude"]!),
      mode: TravelMode.driving,
    );

    List<LatLng> polylineCoordinates = [];

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: polylineRequest,
      googleApiKey: AppConstants.googleMapsDirectionsApiKey,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    setState(() {
      // create a Polyline instance
      // with an id, an RGB color and the list of LatLng pairs

      _polylines.clear();
      Polyline polyline = Polyline(polylineId: PolylineId("poly"), color: Color.fromARGB(255, 40, 122, 198), points: polylineCoordinates);

      // add the constructed polyline as a set of points
      // to the polyline set, which will eventually
      // end up showing up on the map

      _polylines.add(polyline);
    });

    globals.nextStep = globals.nextStep + 1;
  }

  Future<void> _showRouteBuilder() async {
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
              child: RouteBuilder(() async {
                final polylinePoints = PolylinePoints();

                List<LatLng> polylineCoordinates = [];

                PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
                  request: PolylineRequest(
                    origin: PointLatLng(globals.route[0]['location']["latitude"], globals.route[0]['location']["longitude"]),
                    destination: PointLatLng(globals.route[1]['location']["latitude"], globals.route[1]['location']["longitude"]),
                    mode: TravelMode.driving,
                  ),
                  googleApiKey: AppConstants.googleMapsDirectionsApiKey,
                );

                PolylineResult result2 = await polylinePoints.getRouteBetweenCoordinates(
                  request: PolylineRequest(
                    origin: PointLatLng(globals.route[1]['location']["latitude"], globals.route[1]['location']["longitude"]),
                    destination: PointLatLng(globals.route[2]['location']["latitude"], globals.route[2]['location']["longitude"]),
                    mode: TravelMode.driving,
                  ),
                  googleApiKey: AppConstants.googleMapsDirectionsApiKey,
                );

                if (result.points.isNotEmpty) {
                  result.points.forEach((PointLatLng point) {
                    polylineCoordinates.add(LatLng(point.latitude, point.longitude));
                  });
                }

                if (result2.points.isNotEmpty) {
                  result2.points.forEach((PointLatLng point) {
                    polylineCoordinates.add(LatLng(point.latitude, point.longitude));
                  });
                }

                setState(() {
                  // create a Polyline instance
                  // with an id, an RGB color and the list of LatLng pairs
                  Polyline polyline = Polyline(polylineId: PolylineId("poly"), color: Color.fromARGB(255, 40, 122, 198), points: polylineCoordinates);

                  // add the constructed polyline as a set of points
                  // to the polyline set, which will eventually
                  // end up showing up on the map

                  _polylines.add(polyline);
                });
              }),
            ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: <Widget>[
        GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: LatLng(-33.459229, -70.645348),
            zoom: 14.4746,
          ),
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          polylines: _polylines,
          markers: Set<Marker>.of(googleMarkers),
          zoomControlsEnabled: false,
          compassEnabled: false,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
        ),
        Column(
          children: [
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Container(
                      child: ChipsChoice<String>.multiple(
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
                    ))),
            Visibility(
              visible: !isAnonymous && !offline,
              child: Container(
                  child: MaterialButton(
                height: 30,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(200))),
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                child: loading
                    ? CircularProgressIndicator(
                        color: AppColors.white,
                      )
                    : Text(
                        AppLocalizations.of(context)!.recommendRoute,
                        style: new TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15.0,
                          color: Colors.white,
                        ),
                      ),
                onPressed: () {
                  _showRouteBuilder();
                },
                splashColor: Colors.white,
              )),
            ),
            Visibility(
              visible: _stepsMarkers.length > 0 && globals.nextStep < _stepsMarkers.length && !offline,
              child: Container(
                  child: MaterialButton(
                height: 30,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(200))),
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                child: loading
                    ? CircularProgressIndicator(
                        color: AppColors.white,
                      )
                    : Text(
                        AppLocalizations.of(context)!.nextStep, //AppLocalizations.of(context)!.recommendRoute,
                        style: new TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15.0,
                          color: Colors.white,
                        ),
                      ),
                onPressed: () {
                  _routeNextStep();
                },
                splashColor: Colors.white,
              )),
            ),
          ],
        ),

        // Positioned(top: 30, right: 15, left: 15, child: FilterBarWidget(AppLocalizations.of(context)!.filterBarText)),

        Positioned(
          bottom: 10,
          right: 0,
          left: 0,
          child: !loaded
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
                      return TourCarouselWidget(snapshot.data!, true, active, offline);
                    }

                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  },
                )
              : TourCarouselWidget(toursLoaded, true, active, offline),
        ),
      ]),
      floatingActionButton: ActionButton(
        onPressed: _currentLocation,
        icon: Icon(
          MdiIcons.crosshairsGps,
          color: AppColors.white,
        ),
      ),
    );
  }
}

