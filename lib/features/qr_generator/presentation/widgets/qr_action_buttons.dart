import 'package:flutter/material.dart';
import '../../../../../app/theme/app_colors.dart';

class QrActionButtons extends StatelessWidget {
  final bool isSharing;
  final bool isSaving;
  final VoidCallback onShare;
  final VoidCallback onSave;

  const QrActionButtons({
    super.key,
    required this.isSharing,
    required this.isSaving,
    required this.onShare,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton.icon(
          icon: isSharing
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.teal,
                  ),
                )
              : const Icon(
                  Icons.share_rounded,
                  size: 18,
                  color: AppColors.teal,
                ),
          label: Text(
            isSharing ? 'Sharing...' : 'Share',
            style: const TextStyle(color: AppColors.teal),
          ),
          onPressed: isSharing ? null : onShare,
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.teal,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
              : const Icon(Icons.download_rounded, size: 18),
          label: Text(isSaving ? 'Saving...' : 'Save'),
          onPressed: isSaving ? null : onSave,
        ),
      ],
    );
  }
}
