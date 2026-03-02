import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/glassmorphism.dart';
import '../../domain/entities/scan_entity.dart';
import '../bloc/scanner_bloc.dart';
import '../widgets/camera_error_view.dart';
import '../widgets/scan_result_card.dart';
import '../widgets/scanner_overlay.dart';
import '../widgets/scanner_top_bar.dart';

/// Scanner page — QR & Barcode scanning with camera.
class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  MobileScannerController? _controller;
  bool _hasScanned = false;
  bool _cameraError = false;
  String? _scannedData;
  String? _scannedFormat;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  void _initCamera() {
    try {
      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
      );
    } catch (e) {
      setState(() => _cameraError = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    setState(() {
      _hasScanned = true;
      _scannedData = barcode.rawValue;
      _scannedFormat = barcode.format.name;
    });

    // Save to scan history
    final scan = ScanEntity(
      id: const Uuid().v4(),
      scannedData: barcode.rawValue!,
      scanType: barcode.format == BarcodeFormat.qrCode ? 'qr' : 'barcode',
      format: barcode.format.name,
      timestamp: DateTime.now(),
    );
    context.read<ScannerBloc>().add(ScanCompleted(scan));
  }

  void _resetScanner() {
    setState(() {
      _hasScanned = false;
      _scannedData = null;
      _scannedFormat = null;
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (image == null) return;

      final BarcodeCapture? capture = await _controller?.analyzeImage(
        image.path,
      );
      if (capture != null && capture.barcodes.isNotEmpty) {
        _onDetect(capture);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('No QR or barcode found in image'),
              backgroundColor: AppColors.amber,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error reading image: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraError || _controller == null) {
      return const CameraErrorView(message: 'Camera not available');
    }

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Stack(
        children: [
          // ─── Camera Preview ────────────────────────────
          MobileScanner(
            controller: _controller!,
            onDetect: _onDetect,
            errorBuilder: (context, error) {
              return CameraErrorView(
                message: 'Camera error',
                errorDetails:
                    error.errorDetails?.message ?? 'Unable to access camera',
              );
            },
          ),

          // ─── Overlay ──────────────────────────────────
          ScannerOverlay(hasScanned: _hasScanned),

          // ─── Top Bar ──────────────────────────────────
          ScannerTopBar(
            onPickImage: _pickImage,
            controllerState: _controller,
            onToggleTorch: () => _controller!.toggleTorch(),
            onSwitchCamera: () => _controller!.switchCamera(),
          ),

          // ─── Result Card ──────────────────────────────
          if (_hasScanned && _scannedData != null)
            ScanResultCard(
              scannedFormat: _scannedFormat ?? 'Unknown',
              scannedData: _scannedData!,
              onScanAgain: _resetScanner,
            ),
        ],
      ),
    );
  }
}
