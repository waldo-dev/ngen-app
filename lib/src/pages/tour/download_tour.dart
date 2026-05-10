import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:app/src/util/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/core/storage/localstorage_compat.dart';

class DownloadTourWidget extends StatefulWidget {
  final String tourId;
  final String imgPath;

  DownloadTourWidget(this.tourId, this.imgPath);

  @override
  State<DownloadTourWidget> createState() => DownloadTourWidgetState();
}

class DownloadTourWidgetState extends State<DownloadTourWidget> with TickerProviderStateMixin {
  final LocalStorage storage = new LocalStorage('ngen_app');
  bool downloading = false;
  bool downloaded = false;
  bool loading = false;
  int progress = 0;

  void isDownloaded() async {
    Directory documentDirectory = await getApplicationDocumentsDirectory();

    Directory dir = Directory(documentDirectory.path + '/tours');

    if (await dir.exists()) {
      var listOfAllFolderAndFiles = await dir.list(recursive: false).toList();
      List<Directory> toursDirectories = listOfAllFolderAndFiles.whereType<Directory>().toList();

      if (toursDirectories.isNotEmpty) {
        toursDirectories.forEach((element) {
          if (element.path.contains(widget.tourId))
            setState(() {
              downloaded = true;
            });
        });
      }
    }
  }

  getLanguageCodeAmazon(String locale) {
    if (locale == 'zh')
      return 'cmn';
    else if (locale == 'ar')
      return 'arb';
    else
      return locale;
  }

  Future<void> openDownloadTour() {
    return showDialog<void>(
        barrierColor: Colors.white.withOpacity(0),
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return new BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Dialog(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    insetPadding: EdgeInsets.all(10),
                    child: AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(32.0))),
                      title: Text(AppLocalizations.of(context)!.downloadFullTour),
                      actionsPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                      content: SingleChildScrollView(
                        child: ListBody(
                          children: <Widget>[
                            Icon(
                              MdiIcons.trayArrowDown,
                              color: AppColors.primary,
                              size: 60,
                            ),
                            LinearProgressIndicator(
                              value: progress.toDouble() / 100,
                              semanticsLabel: 'Linear progress indicator',
                            ),
                            Center(child: Text('${progress} %')),
                          ],
                        ),
                      ),
                      actions: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            MaterialButton(
                              height: 45,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(200))),
                              color: AppColors.font_light,
                              textColor: Colors.white,
                              child: Text(
                                AppLocalizations.of(context)!.cancelDownloadTour,
                                style: new TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20.0,
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: downloading
                                  ? null
                                  : () {
                                      Navigator.of(context).pop();
                                    },
                              splashColor: Colors.white,
                            ),
                            MaterialButton(
                              height: 45,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(200))),
                              color: Theme.of(context).primaryColor,
                              disabledColor: AppColors.primary,
                              textColor: Colors.white,
                              child: downloading
                                  ? CircularProgressIndicator(
                                      color: AppColors.white,
                                    )
                                  : Text(
                                      AppLocalizations.of(context)!.downloadTourAction,
                                      style: new TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 20.0,
                                        color: Colors.white,
                                      ),
                                    ),
                              onPressed: downloading
                                  ? null
                                  : () async {
                                      setState(() {
                                        downloading = true;
                                      });

                                      try {
                                        var response = await http.get(Uri.parse(widget.imgPath));
                                        Directory documentDirectory = await getApplicationDocumentsDirectory();
                                        File file = await File(documentDirectory.path + '/tours/${widget.tourId}/tourimage').create(recursive: true);
                                        file.writeAsBytesSync(response.bodyBytes);

                                        CollectionReference tours = FirebaseFirestore.instance.collection('tours');
                                        DocumentSnapshot tourInfoDoc = await tours.doc('cl').collection('list').doc(widget.tourId).get();
                                        File tourInfo =
                                            await File(documentDirectory.path + '/tours/${widget.tourId}/tourinfo.json').create(recursive: true);
                                        Map<String, dynamic> tourJson = tourInfoDoc.data() as Map<String, dynamic>;
                                        tourJson['id'] = tourInfoDoc.id;
                                        tourJson['image'] = documentDirectory.path + '/tours/${widget.tourId}/tourimage';
                                        List<Map<String, dynamic>> stepList = [];
                                        QuerySnapshot steps =
                                            await FirebaseFirestore.instance.collection('steps').doc(widget.tourId).collection('list').get();

                                        // print(steps.docs.length);

                                        var locale = getLanguageCodeAmazon(storage.getItem('locale') ?? 'en');
                                        for (var i = 0; i < steps.size; i++) {
                                          print("ETAPA: " + (steps.docs[i].get('title')[locale]));
                                          if (steps.docs[i].get('image') != '') {
                                            var response = await http.get(Uri.parse(steps.docs[i].get('image')));
                                            File stepImageFile =
                                                await File(documentDirectory.path + '/tours/${widget.tourId}/stepimage${steps.docs[i].id}')
                                                    .create(recursive: true);
                                            stepImageFile.writeAsBytesSync(response.bodyBytes);
                                          } else {
                                            var response = await http.get(Uri.parse(widget.imgPath));
                                            File stepImageFile =
                                                await File(documentDirectory.path + '/tours/${widget.tourId}/stepimage${steps.docs[i].id}')
                                                    .create(recursive: true);
                                            stepImageFile.writeAsBytesSync(response.bodyBytes);
                                          }

                                          Map<String, dynamic> stepJson = steps.docs[i].data() as Map<String, dynamic>;
                                          stepJson['id'] = steps.docs[i].id;
                                          Map<String, dynamic> audios = stepJson['audio'];

                                          print("Audio: " + locale);
                                          var audioresponse = await http.get(Uri.parse(audios[locale]));
                                          File audioFile =
                                              await File(documentDirectory.path + '/tours/${widget.tourId}/${steps.docs[i].id}/${locale}/audiofile')
                                                  .create(recursive: true);
                                          audioFile.writeAsBytesSync(audioresponse.bodyBytes);
                                          stepJson['audio'][locale] =
                                              documentDirectory.path + '/tours/${widget.tourId}/${steps.docs[i].id}/${locale}/audiofile';

                                          stepJson['image'] = documentDirectory.path + '/tours/${widget.tourId}/stepimage${steps.docs[i].id}';
                                          stepList.add(stepJson);
                                          setState(() {
                                            progress = ((i + 1) * 100 / steps.size).round();
                                          });

                                          print(progress);
                                        }
                                        // print(stepList);
                                        tourJson['steps'] = stepList;
                                        tourInfo.writeAsString(jsonEncode(tourJson));
                                      } catch (e) {
                                        print("ERROR");
                                        print(e);
                                      }

                                      Navigator.of(context).pop();
                                      setState(() {
                                        downloading = false;
                                        downloaded = true;
                                      });
                                    },
                              splashColor: Colors.white,
                            )
                          ],
                        )
                      ],
                    )));
          });
        });
  }

  void deleteTour() async {
    setState(() {
      downloading = true;
    });

    try {
      Directory documentDirectory = await getApplicationDocumentsDirectory();

      Directory dir = Directory(documentDirectory.path + '/tours/${widget.tourId}');

      if (await dir.exists()) {
        dir.deleteSync(recursive: true);
        Navigator.of(context).pop();
      }
    } catch (e) {
      print(e);
    }

    setState(() {
      downloading = false;
      downloaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    isDownloaded();
    return Container(
        width: 50,
        padding: EdgeInsets.zero,
        child: MaterialButton(
          onPressed: () {
            if (downloaded) {
              deleteTour();
            } else {
              openDownloadTour();
            }
          },
          elevation: 4,
          splashColor: AppColors.primary,
          color: Colors.white,
          textColor: Colors.white,
          child: downloading
              ? CircularProgressIndicator()
              : Icon(
                  downloaded ? MdiIcons.delete : MdiIcons.download,
                  color: AppColors.primary,
                  size: 30,
                ),
          padding: EdgeInsets.all(8),
          shape: CircleBorder(),
        ));
  }
}

