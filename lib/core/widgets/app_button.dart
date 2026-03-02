import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// A premium raised button with depth, gradients, and proper contrast.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.variant = AppButtonVariant.primary,
    this.isExpanded = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final AppButtonVariant variant;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null && !isLoading;

    final buttonChild = Row(
      mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(
                variant == AppButtonVariant.primary
                    ? AppColors.white
                    : AppColors.darkTeal,
              ),
            ),
          ),
          const SizedBox(width: 12),
        ] else if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: 10),
        ],
        Text(label),
      ],
    );

    final style = _getStyle(isDisabled);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDisabled
            ? []
            : [
                BoxShadow(
                  color: _getShadowColor(),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: _getShadowColor().withValues(alpha: 0.12),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: isExpanded
          ? SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: style,
                onPressed: isLoading ? null : onPressed,
                child: buttonChild,
              ),
            )
          : ElevatedButton(
              style: style,
              onPressed: isLoading ? null : onPressed,
              child: buttonChild,
            ),
    );
  }

  ButtonStyle _getStyle(bool isDisabled) {
    switch (variant) {
      case AppButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: isDisabled
              ? AppColors.teal.withValues(alpha: 0.4)
              : AppColors.teal,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.teal.withValues(alpha: 0.4),
          disabledForegroundColor: AppColors.white.withValues(alpha: 0.7),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        );
      case AppButtonVariant.secondary:
        return ElevatedButton.styleFrom(
          backgroundColor: isDisabled
              ? AppColors.orange.withValues(alpha: 0.4)
              : AppColors.orange,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.orange.withValues(alpha: 0.4),
          disabledForegroundColor: AppColors.white.withValues(alpha: 0.7),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        );
      case AppButtonVariant.outline:
        return ElevatedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.teal,
          disabledBackgroundColor: AppColors.lightGray.withValues(alpha: 0.5),
          disabledForegroundColor: AppColors.mediumGray,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: isDisabled ? AppColors.lightGray : AppColors.teal,
              width: 1.5,
            ),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        );
      case AppButtonVariant.ghost:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.teal,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
        );
    }
  }

  Color _getShadowColor() {
    switch (variant) {
      case AppButtonVariant.primary:
        return AppColors.teal.withValues(alpha: 0.40);
      case AppButtonVariant.secondary:
        return AppColors.orange.withValues(alpha: 0.40);
      case AppButtonVariant.outline:
        return AppColors.shadowLight;
      case AppButtonVariant.ghost:
        return Colors.transparent;
    }
  }
}

enum AppButtonVariant { primary, secondary, outline, ghost }
