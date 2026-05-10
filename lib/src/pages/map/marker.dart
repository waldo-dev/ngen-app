import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app/src/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart' as svg_parser;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NgenMarker {
  String id = '';
  String text = '';
  LatLng position = LatLng(0, 0);
  final VoidCallback callback;

  NgenMarker(this.id, this.text, this.position, this.callback);

  Future<Marker> getMarker() {
    return drawMarker(text).then((value) {
      return Marker(
          markerId: MarkerId(this.id),
          position: this.position,
          icon: BitmapDescriptor.fromBytes(value),
          onTap: () {
            callback();
            // print("MARKER ID: ${this.id}");
          }
          // infoWindow: InfoWindow(title: "Hola", snippet: '*'),
          );
    });
  }

  Size _textSize(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(text: TextSpan(text: text, style: style), maxLines: 1, textDirection: TextDirection.ltr)
      ..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  Future<Uint8List> drawMarker(String title) async {
    double width = 100;
    double height = 100;
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final String rawSvg = '''<svg xmlns="http://www.w3.org/2000/svg" width="818.48" height="981.36" viewBox="0 0 818.48 981.36">
  <title>markerNgen</title>
  <path d="M499.05,12.7H892.28A8.75,8.75,0,0,1,901,21.46V435.21a402,402,0,0,1-402,402h0a402,402,0,0,1-402-402V414.69a402,402,0,0,1,402-402Z" transform="translate(1062.6 356.84) rotate(135)" fill="#7225d7"/>
  <rect x="491.78" y="186.36" width="114.06" height="465.54" rx="57.03" fill="#fff"/>
  <rect x="441.18" y="155.19" width="114.06" height="562" rx="57.03" transform="translate(-253.18 392.2) rotate(-38.75)" fill="#fff"/>
  <rect x="208.49" y="186.36" width="114.06" height="465.54" rx="57.03" fill="#fff"/>
</svg>
''';
    final DrawableRoot svgRoot = await svg_parser.svg.fromSvgString(rawSvg, rawSvg);

    svgRoot.scaleCanvasToViewBox(canvas, Size(width, height));
    svgRoot.clipCanvasToViewBox(canvas);
    svgRoot.draw(canvas, Rect.zero);

    // TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    // painter.text = TextSpan(
    //   text: title,
    //   style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.normal, color: AppColors.white, fontFamily: "Open Sans"),
    // );
    // painter.layout();
    // painter.paint(canvas, Offset((width * 0.5) - painter.width * 0.5, (height * 0.5) - painter.height * 0.5));
    final img = await pictureRecorder.endRecording().toImage(width.toInt(), height.toInt() + 30);
    final data = await img.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }
}
