import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Glassmorphism styling helpers for frosted glass panels,
/// transparent cards, and floating surfaces.
class Glassmorphism {
  Glassmorphism._();

  // ─── Standard Glass Decoration ─────────────────────────
  static BoxDecoration glass({
    double opacity = 0.65,
    double borderRadius = 20,
    double borderOpacity = 0.75,
    double blurRadius = 12,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: opacity),
          Colors.white.withValues(alpha: opacity * 0.85),
        ],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withValues(alpha: borderOpacity),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.darkTeal.withValues(alpha: 0.10),
          blurRadius: blurRadius,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: AppColors.darkTeal.withValues(alpha: 0.05),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  // ─── Frosted Glass Decoration (heavier blur) ───────────
  static BoxDecoration frosted({
    double opacity = 0.70,
    double borderRadius = 24,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: opacity),
          Colors.white.withValues(alpha: opacity * 0.88),
        ],
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.80),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.darkTeal.withValues(alpha: 0.12),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: AppColors.darkTeal.withValues(alpha: 0.06),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // ─── Floating Surface (elevated glass) ─────────────────
  static BoxDecoration floating({double borderRadius = 20, Color? tint}) {
    return BoxDecoration(
      color: (tint ?? AppColors.warmWhite).withValues(alpha: 0.88),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.85),
        width: 1.0,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.darkTeal.withValues(alpha: 0.10),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: AppColors.darkTeal.withValues(alpha: 0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // ─── BackdropFilter wrapper ────────────────────────────
  static Widget blurredBackground({
    required Widget child,
    double sigmaX = 12,
    double sigmaY = 12,
    double borderRadius = 20,
    double opacity = 0.65,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: Container(
          decoration: glass(opacity: opacity, borderRadius: borderRadius),
          child: child,
        ),
      ),
    );
  }
}
