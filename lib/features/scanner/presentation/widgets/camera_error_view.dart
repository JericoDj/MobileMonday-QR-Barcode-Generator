import 'package:flutter/material.dart';
import '../../../../../app/theme/app_colors.dart';

class CameraErrorView extends StatelessWidget {
  final String message;
  final String? errorDetails;

  const CameraErrorView({super.key, required this.message, this.errorDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.no_photography_rounded,
              size: 64,
              color: AppColors.mediumGray.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(message, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              errorDetails ?? 'Use a physical device to scan',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
