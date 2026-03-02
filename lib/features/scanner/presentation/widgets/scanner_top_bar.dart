import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../app/theme/glassmorphism.dart';

class ScannerTopBar extends StatelessWidget {
  final VoidCallback onPickImage;
  final ValueListenable<MobileScannerState>? controllerState;
  final VoidCallback onToggleTorch;
  final VoidCallback onSwitchCamera;

  const ScannerTopBar({
    super.key,
    required this.onPickImage,
    required this.controllerState,
    required this.onToggleTorch,
    required this.onSwitchCamera,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: Glassmorphism.glass(opacity: 0.2, borderRadius: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Scanner',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.image_rounded,
                            color: AppColors.white,
                          ),
                          onPressed: onPickImage,
                        ),
                        if (controllerState != null)
                          IconButton(
                            icon: ValueListenableBuilder<MobileScannerState>(
                              valueListenable: controllerState!,
                              builder: (_, state, _) {
                                return Icon(
                                  state.torchState == TorchState.on
                                      ? Icons.flash_on_rounded
                                      : Icons.flash_off_rounded,
                                  color: AppColors.white,
                                );
                              },
                            ),
                            onPressed: onToggleTorch,
                          ),
                        IconButton(
                          icon: const Icon(
                            Icons.flip_camera_ios_rounded,
                            color: AppColors.white,
                          ),
                          onPressed: onSwitchCamera,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
