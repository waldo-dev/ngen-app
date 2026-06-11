import 'package:app/core/api/ngen_functions.dart';
import 'package:app/src/pages/tour/tour_payment_placeholder.dart';
import 'package:app/src/widgets/tour_presentation_prompt.dart';
import 'package:flutter/material.dart';

/// Bloquea el contenido del tour hasta tener unlock (QR, compra o presentación).
class TourAccessGate extends StatefulWidget {
  const TourAccessGate({
    super.key,
    required this.tourId,
    required this.tier,
    required this.child,
    this.offline = false,
    this.price = 0,
    this.currency = 'CLP',
    this.isPresentation = false,
  });

  final String tourId;
  final int tier;
  final int price;
  final String currency;
  final bool offline;
  final bool isPresentation;
  final Widget child;

  @override
  State<TourAccessGate> createState() => _TourAccessGateState();
}

class _TourAccessGateState extends State<TourAccessGate> {
  final NgenFunctions _functions = NgenFunctions();
  bool _loading = true;
  bool _allowed = false;
  String? _reason;

  bool get _requiresUnlock =>
      !widget.offline && (widget.tier > 0 || widget.price > 0);

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    if (!_requiresUnlock) {
      setState(() {
        _loading = false;
        _allowed = true;
      });
      return;
    }

    try {
      final result = await _functions.checkTourAccess(tourId: widget.tourId);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _allowed = result.allowed;
        _reason = result.reason;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _allowed = false;
        _reason = 'error';
      });
    }
  }

  Future<void> _onUnlocked() => _checkAccess();

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_allowed) {
      return widget.child;
    }

    if (widget.isPresentation) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TourPresentationPrompt(
            tourId: widget.tourId,
            price: widget.price,
            currency: widget.currency,
            onUnlocked: _onUnlocked,
          ),
          if (widget.price > 0)
            TourPaymentPlaceholder(
              tourId: widget.tourId,
              price: widget.price,
              currency: widget.currency,
              reason: _reason,
              onUnlocked: _onUnlocked,
            ),
        ],
      );
    }

    return TourPaymentPlaceholder(
      tourId: widget.tourId,
      price: widget.price,
      currency: widget.currency,
      reason: _reason,
      onUnlocked: _onUnlocked,
    );
  }
}
