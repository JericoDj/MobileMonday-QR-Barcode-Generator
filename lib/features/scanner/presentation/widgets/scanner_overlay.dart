import 'package:flutter/material.dart';
import '../../../../../app/theme/app_colors.dart';

class ScannerOverlay extends StatelessWidget {
  final bool hasScanned;

  const ScannerOverlay({super.key, required this.hasScanned});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 260,
        height: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: hasScanned
                ? AppColors.success.withValues(alpha: 0.8)
                : AppColors.amber.withValues(alpha: 0.6),
            width: 3,
          ),
        ),
      ),
    );
  }
}
