import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

class PermissionDialog extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onCancel;
  final String title;
  final String description;
  final IconData icon;

  const PermissionDialog({
    super.key,
    required this.onContinue,
    required this.onCancel,
    this.title = 'Permissions Required',
    this.description =
        'This app needs access to your camera and storage/photos to function properly.',
    this.icon = Icons.security_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Icon(icon, color: AppColors.forest, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                color: AppColors.forest,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        description,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          color: AppColors.charcoal,
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: onCancel,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.charcoal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: const Text(
            'Not Now',
            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500),
          ),
        ),
        ElevatedButton(
          onPressed: onContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.forest,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Continue',
            style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
          ),
        ),
      ],
      actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
      contentPadding: const EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: 24,
      ),
    );
  }
}
