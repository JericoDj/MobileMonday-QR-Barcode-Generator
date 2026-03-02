import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/glassmorphism.dart';

class GeneratorTabBar extends StatelessWidget {
  final TabController controller;
  final ValueChanged<int> onTap;

  const GeneratorTabBar({
    super.key,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: Glassmorphism.glass(opacity: 0.12, borderRadius: 16),
            child: TabBar(
              controller: controller,
              indicator: BoxDecoration(
                color: AppColors.forest,
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: AppColors.white,
              unselectedLabelColor: AppColors.darkGray,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: 'QR Code'),
                Tab(text: 'Barcode'),
              ],
              onTap: onTap,
            ),
          ),
        ),
      ),
    );
  }
}
