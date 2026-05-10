import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:app/src/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart' as svg_parser;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMarker {
  String id = '';
  String text = '';
  LatLng position = LatLng(0, 0);
  final VoidCallback callback;

  GoogleMarker(this.id, this.text, this.position, this.callback);

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
    double width = 60;
    double height = 60;
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final String rawSvg = '''<svg xmlns="http://www.w3.org/2000/svg" width="818.48" height="981.36" viewBox="0 0 818.48 981.36">
  <title>MarkerGoogle</title>
  <path d="M499.05,12.7H892.28A8.75,8.75,0,0,1,901,21.46V435.21a402,402,0,0,1-402,402h0a402,402,0,0,1-402-402V414.69a402,402,0,0,1,402-402Z" transform="translate(1062.6 356.84) rotate(135)" fill="#ea4335"/>
  <path d="M737.29,423.52H510.47V491h161c-8.16,94.25-86.57,134.57-160.78,134.57-94.73,0-177.85-74.71-177.85-179.83C332.86,344.36,412,266,511,266c76.43,0,121.2,48.73,121.2,48.73l47-49s-60.35-67.28-170.67-67.28C368,198.42,259.4,317.15,259.4,445.78c0,124.91,102.16,247.35,252.8,247.35,132.33,0,228.8-90.78,228.8-224.84,0-28.45-3.71-44.77-3.71-44.77Z" transform="translate(-89.82 -15.71)" fill="#fff"/>
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
