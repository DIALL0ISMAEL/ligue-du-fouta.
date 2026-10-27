import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/supabase_service.dart';
import '../theme/app_theme.dart';
import 'manual_input_screen.dart';
import 'validation_result_screen.dart';

class QrScannerScreen extends StatefulWidget {
  final String? currentMatchId;
  const QrScannerScreen({super.key, this.currentMatchId});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.trim().isEmpty) return;

    setState(() => _isProcessing = true);

    final result = await SupabaseService().validateTicket(
      ticketCode: rawValue,
      currentMatchId: widget.currentMatchId,
    );

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ValidationResultScreen(
          result: result,
          onScanNext: () {
            setState(() => _isProcessing = false);
          },
        ),
      ),
    );

    if (mounted) {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scanner de Billets'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: ValueListenableBuilder<TorchState>(
              valueListenable: _controller.torchState,
              builder: (context, state, child) {
                return Icon(
                  state == TorchState.on ? Icons.flash_on : Icons.flash_off,
                  color: state == TorchState.on ? AppTheme.gold : Colors.white,
                );
              },
            ),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Caméra MobileScanner
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Cadre de visée animé
          Center(
            child: Container(
              width: 270,
              height: 270,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.primaryGreen, width: 3),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(width: 24, height: 4, color: AppTheme.gold),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(width: 24, height: 4, color: AppTheme.gold),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(width: 24, height: 4, color: AppTheme.gold),
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(width: 24, height: 4, color: AppTheme.gold),
                  ),
                ],
              ),
            ),
          ),

          // Indicateur de chargement
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppTheme.primaryGreen),
                    SizedBox(height: 16),
                    Text(
                      'Validation atomique en cours...',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),

          // Barre d'action inférieure
          Positioned(
            left: 20,
            right: 20,
            bottom: 30,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ManualInputScreen(currentMatchId: widget.currentMatchId),
                        ),
                      );
                    },
                    icon: const Icon(Icons.dialpad, color: Colors.white),
                    label: const Text('Saisie Manuelle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.cardSurface,
                      side: const BorderSide(color: AppTheme.cardBorder),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
