import 'dart:async';

import 'package:app/core/api/ngen_functions.dart';
import 'package:app/src/pages/tour/qr_tour_detail_page.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

/// Escucha deep links `ngen://t/{qrSlug}` y HTTP `/t/{qrSlug}`.
/// El QR identifica solo el tour; el idioma lo elige el turista en la app.
class TourQrHandler extends StatefulWidget {
  const TourQrHandler({super.key, required this.navigatorKey, required this.child});

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  State<TourQrHandler> createState() => _TourQrHandlerState();
}

class _TourQrHandlerState extends State<TourQrHandler> {
  final NgenFunctions _functions = NgenFunctions();
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSub;
  bool _handling = false;

  @override
  void initState() {
    super.initState();
    _listenLinks();
  }

  Future<void> _listenLinks() async {
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        await _handleUri(initial);
      }
    } catch (_) {}

    _linkSub = _appLinks.uriLinkStream.listen((uri) {
      _handleUri(uri);
    });
  }

  String? _extractQrSlug(Uri uri) {
    if (uri.scheme == 'ngen' && uri.host == 't') {
      final path = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : uri.path.replaceFirst('/', '');
      return path.isNotEmpty ? path : null;
    }

    final segments = uri.pathSegments;
    if (segments.length >= 2 && segments[segments.length - 2] == 't') {
      return segments.last;
    }
    if (segments.length == 1 && segments.first == 't' && uri.queryParameters['slug'] != null) {
      return uri.queryParameters['slug'];
    }
    if (segments.length == 1 && uri.path.startsWith('/t/')) {
      return uri.path.replaceFirst('/t/', '');
    }
    return null;
  }

  Future<void> _handleUri(Uri uri) async {
    final slug = _extractQrSlug(uri);
    if (slug == null || slug.isEmpty || _handling) return;

    _handling = true;
    try {
      final meta = await _functions.resolveTourQr(qrSlug: slug);
      final tourId = meta['tourId'] as String?;
      final countryId = meta['countryId'] as String? ?? 'cl';
      if (tourId == null || tourId.isEmpty) return;

      await _functions.startTourFromQr(
        qrSlug: slug,
        tourId: tourId,
        countryId: countryId,
      );

      widget.navigatorKey.currentState?.push(
        MaterialPageRoute<void>(
          builder: (_) => QrTourDetailPage(
            tourId: tourId,
            countryId: countryId,
          ),
        ),
      );
    } catch (e) {
      debugPrint('[TourQrHandler] $e');
    } finally {
      _handling = false;
    }
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
