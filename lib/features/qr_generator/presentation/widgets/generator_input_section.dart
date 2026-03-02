import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../app/theme/app_colors.dart';
import '../../../../../core/widgets/app_button.dart';

class GeneratorInputSection extends StatelessWidget {
  final bool isQr;
  final Map<String, dynamic> info;
  final TextEditingController titleController;
  final TextEditingController dataController;
  final String? validationError;
  final bool isLoading;
  final VoidCallback onClear;
  final VoidCallback onGenerate;
  final List<TextInputFormatter> inputFormatters;

  const GeneratorInputSection({
    super.key,
    required this.isQr,
    required this.info,
    required this.titleController,
    required this.dataController,
    required this.validationError,
    required this.isLoading,
    required this.onClear,
    required this.onGenerate,
    required this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Title Field ─────────────────────────────
        TextField(
          controller: titleController,
          maxLength: 100,
          decoration: InputDecoration(
            labelText: 'Title (optional)',
            hintText: 'e.g., My Website QR',
            prefixIcon: const Icon(Icons.title_rounded, color: AppColors.sage),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 16),

        // ─── Data Input with Validation ───────────────
        TextField(
          controller: dataController,
          maxLines: isQr ? 3 : 1,
          keyboardType:
              info['keyboard'] as TextInputType? ?? TextInputType.text,
          maxLength: info['maxLength'] as int? ?? 2000,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            labelText: info['label'] as String,
            hintText: info['placeholder'] as String,
            helperText: info['hint'] as String,
            helperMaxLines: 2,
            errorText: validationError,
            errorMaxLines: 2,
            prefixIcon: Icon(
              isQr ? Icons.qr_code_rounded : Icons.view_week_rounded,
              color: AppColors.sage,
            ),
            suffixIcon: dataController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.clear_rounded,
                      color: AppColors.mediumGray,
                    ),
                    onPressed: onClear,
                  )
                : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
        const SizedBox(height: 24),

        // ─── Generate Button ─────────────────────────
        AppButton(
          label: isQr ? 'Generate QR Code' : 'Generate Barcode',
          icon: Icons.auto_awesome_rounded,
          isLoading: isLoading,
          isExpanded: true,
          onPressed: dataController.text.isEmpty || validationError != null
              ? null
              : onGenerate,
        ),
      ],
    );
  }
}
