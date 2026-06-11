import 'package:app/core/api/ngen_functions.dart';
import 'package:app/core/api/ngen_functions_exception.dart';
import 'package:app/src/util/colors.dart';
import 'package:flutter/material.dart';

/// Vista previa gratuita para tours marcados como presentación.
class TourPresentationPrompt extends StatefulWidget {
  const TourPresentationPrompt({
    super.key,
    required this.tourId,
    required this.onUnlocked,
    this.price = 0,
    this.currency = 'CLP',
  });

  final String tourId;
  final int price;
  final String currency;
  final VoidCallback onUnlocked;

  @override
  State<TourPresentationPrompt> createState() => _TourPresentationPromptState();
}

class _TourPresentationPromptState extends State<TourPresentationPrompt> {
  final NgenFunctions _functions = NgenFunctions();
  bool _processing = false;
  String? _error;

  Future<void> _startPresentation() async {
    setState(() {
      _processing = true;
      _error = null;
    });

    try {
      await _functions.startPresentationAccess(tourId: widget.tourId);
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xfff3f8ff),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffcee5ff)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Tour de presentación',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.font_black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.price > 0
                ? 'Puedes iniciar una vista previa gratuita. Para el tour completo, compra en la app o escanea el QR del guía.'
                : 'Inicia la vista previa gratuita para escuchar las paradas.',
            style: const TextStyle(fontSize: 14, color: AppColors.font_light, height: 1.4),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _processing ? null : _startPresentation,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: _processing
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Iniciar vista previa gratis'),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}
