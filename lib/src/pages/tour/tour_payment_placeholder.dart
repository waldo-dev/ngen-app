import 'package:app/core/api/ngen_functions.dart';
import 'package:app/core/api/ngen_functions_exception.dart';
import 'package:app/src/util/colors.dart';
import 'package:flutter/material.dart';

/// Pantalla de pago en la app (pasarela real pendiente; desbloqueo de prueba disponible).
class TourPaymentPlaceholder extends StatefulWidget {
  const TourPaymentPlaceholder({
    super.key,
    required this.tourId,
    required this.price,
    required this.currency,
    required this.onUnlocked,
    this.reason,
  });

  final String tourId;
  final int price;
  final String currency;
  final String? reason;
  final VoidCallback onUnlocked;

  @override
  State<TourPaymentPlaceholder> createState() => _TourPaymentPlaceholderState();
}

class _TourPaymentPlaceholderState extends State<TourPaymentPlaceholder> {
  final NgenFunctions _functions = NgenFunctions();
  bool _processing = false;
  String? _error;

  String get _formattedPrice {
    if (widget.price <= 0) return '—';
    return '${widget.price} ${widget.currency}';
  }

  Future<void> _simulatePurchase() async {
    setState(() {
      _processing = true;
      _error = null;
    });

    try {
      final paymentId = 'dev_test_${DateTime.now().millisecondsSinceEpoch}';
      await _functions.unlockTourPurchase(
        tourId: widget.tourId,
        paymentId: paymentId,
        amount: widget.price > 0 ? widget.price : 1,
        currency: widget.currency,
      );
      widget.onUnlocked();
    } on NgenFunctionsException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _processing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final expired = widget.reason == 'expired';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xfff8f5fc),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffe4d9ef)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            expired ? 'Tu acceso a este tour expiró' : 'Tour de pago',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.font_black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            expired
                ? 'Vuelve a comprar el tour o escanea el QR del operador para acceder sin pago en la app.'
                : 'Para ver las paradas debes comprar este tour en la app. Si tienes el QR del operador, escanéalo: el acceso por QR no requiere pago aquí.',
            style: const TextStyle(fontSize: 14, color: AppColors.font_light, height: 1.4),
          ),
          if (widget.price > 0) ...[
            const SizedBox(height: 12),
            Text(
              'Precio: $_formattedPrice',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _processing ? null : _simulatePurchase,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: _processing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Comprar tour (prueba)'),
          ),
          const SizedBox(height: 8),
          const Text(
            'La pasarela de pago real (Webpay, PayPal, etc.) se integrará próximamente. '
            'Este botón registra una compra de prueba en el backend.',
            style: TextStyle(fontSize: 12, color: AppColors.font_light, height: 1.35),
            textAlign: TextAlign.center,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(fontSize: 12, color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
