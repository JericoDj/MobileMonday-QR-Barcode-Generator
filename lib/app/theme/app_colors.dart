import 'package:flutter/material.dart';

/// Core color palette for LeosPOS app.
/// Inspired by LeosGroup brand: mint, teal, dark teal, orange.
class AppColors {
  AppColors._();

  // ─── Primary Palette ───────────────────────────────────────
  static const Color mint = Color(0xFFF5FBE6); // Light mint #F5FBE6
  static const Color teal = Color(0xFF215E61); // Teal #215E61
  static const Color darkTeal = Color(0xFF233D4D); // Dark teal #233D4D
  static const Color orange = Color(0xFFFE7F2D); // Orange #FE7F2D

  // ─── Extended Primary ──────────────────────────────────────
  static const Color lightTeal = Color(0xFF2D7A7E);
  static const Color deepOrange = Color(0xFFE56A1A);
  static const Color softMint = Color(0xFFEAF5D4);
  static const Color paleMint = Color(0xFFF0F7DF);

  // ─── Neutrals ──────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF7F9F2);
  static const Color warmWhite = Color(0xFFFBFCF7);
  static const Color lightGray = Color(0xFFE2E6DA);
  static const Color mediumGray = Color(0xFF8A9185);
  static const Color darkGray = Color(0xFF4A524A);
  static const Color charcoal = Color(0xFF2A2F2A);
  static const Color black = Color(0xFF1A1E1A);

  // ─── Semantic ──────────────────────────────────────────────
  static const Color success = Color(0xFF2E8B57);
  static const Color error = Color(0xFFC62828);
  static const Color warning = Color(0xFFE68A00);
  static const Color info = Color(0xFF0288D1);

  // ─── Legacy aliases (backward compat) ─────────────────────
  /// Use [teal] going forward
  static const Color forest = teal;

  /// Use [orange] going forward
  static const Color amber = orange;

  /// Use [mint] going forward
  static const Color cream = mint;

  /// Use [teal] going forward
  static const Color sage = lightTeal;

  // ─── Glassmorphism ─────────────────────────────────────────
  static Color glassWhite = Colors.white.withValues(alpha: 0.60);
  static Color glassBorder = Colors.white.withValues(alpha: 0.70);
  static Color glassSurface = Colors.white.withValues(alpha: 0.40);
  static Color glassOverlay = mint.withValues(alpha: 0.25);
  static Color shadowLight = darkTeal.withValues(alpha: 0.08);
  static Color shadowMedium = darkTeal.withValues(alpha: 0.14);

  // ─── Gradients ─────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [orange, deepOrange],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [mint, warmWhite, offWhite],
    stops: [0.0, 0.35, 1.0],
  );

  static const LinearGradient tealGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightTeal, teal],
  );

  /// Alias for backward compat
  static const LinearGradient forestGradient = tealGradient;

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFCFDF7), Color(0xFFF5FBE6)],
  );

  // ─── Extra – used in branding accents ──────────────────────
  static const Color deepAmber = deepOrange; // alias
}
