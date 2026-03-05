import 'package:flutter/material.dart';
import '../../../../../app/theme/app_colors.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_widget/barcode_widget.dart' as bw;
import '../../../../../core/widgets/glass_card.dart';
import '../../../../../core/widgets/qr_corner_frame.dart';
import 'qr_action_buttons.dart';

class QrPreviewCard extends StatelessWidget {
  final GlobalKey previewKey;
  final bool isQr;
  final String generatedData;
  final bw.Barcode barcodeType;
  final bool isSharing;
  final bool isSaving;
  final VoidCallback onShare;
  final VoidCallback onSave;

  const QrPreviewCard({
    super.key,
    required this.previewKey,
    required this.isQr,
    required this.generatedData,
    required this.barcodeType,
    required this.isSharing,
    required this.isSaving,
    required this.onShare,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text('Preview', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          RepaintBoundary(
            key: previewKey,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: isQr
                  ? QrCornerFrame(
                      size: 240,
                      cornerLength: 32,
                      strokeWidth: 5,
                      padding: 8,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          QrImageView(
                            data: generatedData,
                            version: QrVersions.auto,
                            errorCorrectionLevel: QrErrorCorrectLevel.H,
                            size: 200,
                            backgroundColor: AppColors.white,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: AppColors.darkTeal,
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: AppColors.charcoal,
                            ),
                          ),
                          // Center logo overlay
                          Container(
                            width: MediaQuery.sizeOf(context).width * 0.1,
                            height: MediaQuery.sizeOf(context).height * 0.05,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.darkTeal.withValues(
                                    alpha: 0.12,
                                  ),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(4),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.asset(
                                'assets/leos-logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : QrCornerFrame(
                      width: 260,
                      height: 160,
                      cornerLength: 32,
                      strokeWidth: 5,
                      padding: 12,
                      child: Center(
                        child: SizedBox(
                          height: 80,
                          child: bw.BarcodeWidget(
                            data: generatedData,
                            barcode: barcodeType,
                            drawText: true,
                            color: AppColors.charcoal,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: AppColors.darkGray,
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          QrActionButtons(
            isSharing: isSharing,
            isSaving: isSaving,
            onShare: onShare,
            onSave: onSave,
          ),
        ],
      ),
    );
  }
}
