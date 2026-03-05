import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../../core/widgets/qr_corner_frame.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../qr_generator/domain/entities/generated_item_entity.dart';
import '../bloc/files_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:barcode_widget/barcode_widget.dart' as bw;

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

/// Files page — displays user's generated QR/barcodes with preview.
class FilesPage extends StatefulWidget {
  const FilesPage({super.key});

  @override
  State<FilesPage> createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    _currentUserId = authState is AuthAuthenticated ? authState.user.id : null;
    context.read<FilesBloc>().add(LoadUserFiles(userId: _currentUserId));
  }

  Future<void> _onRefresh() async {
    context.read<FilesBloc>().add(LoadUserFiles(userId: _currentUserId));
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _showPreviewDialog(GeneratedItemEntity item) {
    showDialog(
      context: context,
      builder: (context) => _ItemPreviewDialog(item: item),
    );
  }

  bw.Barcode _getBarcodeType(String format) {
    switch (format) {
      case 'code128':
        return bw.Barcode.code128();
      case 'code39':
        return bw.Barcode.code39();
      case 'ean13':
        return bw.Barcode.ean13();
      case 'ean8':
        return bw.Barcode.ean8();
      case 'upcA':
        return bw.Barcode.upcA();
      case 'pdf417':
        return bw.Barcode.pdf417();
      default:
        return bw.Barcode.code128();
    }
  }

  Future<void> _testScannedImage() async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (image == null) return;

      final controller = MobileScannerController();
      final BarcodeCapture? capture = await controller.analyzeImage(image.path);
      await controller.dispose();

      if (capture != null && capture.barcodes.isNotEmpty) {
        final barcode = capture.barcodes.first;
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.forest),
                SizedBox(width: 8),
                Text('Test Scan Details'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Scan Result:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  barcode.rawValue ?? 'No readable data',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Format:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(barcode.format.name),
              ],
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.forest,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No QR or barcode found in image.'),
            backgroundColor: AppColors.amber,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error analyzing image: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Files',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.charcoal,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.document_scanner_rounded,
                      color: AppColors.white,
                    ),
                    tooltip: 'Test Scanned Image',
                    onPressed: _testScannedImage,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.teal,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<FilesBloc, FilesState>(
                builder: (context, state) {
                  if (state is FilesLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.forest),
                    );
                  }
                  if (state is FilesLoaded) {
                    if (state.files.isEmpty) {
                      return _buildEmptyState();
                    }
                    return RefreshIndicator(
                      onRefresh: _onRefresh,
                      color: AppColors.forest,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: state.files.length,
                        itemBuilder: (context, index) {
                          return _buildFileCard(state.files[index]);
                        },
                      ),
                    );
                  }
                  if (state is FilesError) {
                    return Center(child: Text(state.message));
                  }
                  return _buildEmptyState();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_rounded,
            size: 64,
            color: AppColors.mediumGray.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No files yet',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.mediumGray),
          ),
          const SizedBox(height: 8),
          Text(
            'Generated QR codes & barcodes\nwill appear here',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  void _confirmDelete(GeneratedItemEntity item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_outline_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Delete Item'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${item.title ?? item.format}"? This cannot be undone.',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: AppColors.charcoal,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              // Delete from both Firestore and local via FilesBloc
              context.read<FilesBloc>().add(
                DeleteFileItemRequested(
                  itemId: item.id,
                  userId: _currentUserId,
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Item deleted'),
                  backgroundColor: AppColors.teal,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildFileCard(GeneratedItemEntity item) {
    return GlassCard(
      onTap: () => _showPreviewDialog(item),
      child: Row(
        children: [
          // Mini preview
          Container(
            width: 56,
            height: 56,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.lightGray),
            ),
            child: item.type == 'qr'
                ? QrImageView(
                    data: item.data,
                    version: QrVersions.auto,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: AppColors.forest,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: AppColors.charcoal,
                    ),
                  )
                : bw.BarcodeWidget(
                    data: item.data,
                    barcode: _getBarcodeType(item.format),
                    drawText: false,
                    color: AppColors.charcoal,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title ?? item.format,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.charcoal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.data,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppColors.mediumGray,
                  ),
                ),
              ],
            ),
          ),
          // Delete button
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              color: AppColors.error.withValues(alpha: 0.6),
              size: 20,
            ),
            onPressed: () => _confirmDelete(item),
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }
}

class _ItemPreviewDialog extends StatefulWidget {
  final GeneratedItemEntity item;
  const _ItemPreviewDialog({required this.item});

  @override
  State<_ItemPreviewDialog> createState() => _ItemPreviewDialogState();
}

class _ItemPreviewDialogState extends State<_ItemPreviewDialog> {
  final _previewKey = GlobalKey();
  bool _isSaving = false;
  bool _isSharing = false;

  bw.Barcode _getBarcodeType(String format) {
    switch (format) {
      case 'code128':
        return bw.Barcode.code128();
      case 'code39':
        return bw.Barcode.code39();
      case 'ean13':
        return bw.Barcode.ean13();
      case 'ean8':
        return bw.Barcode.ean8();
      case 'upcA':
        return bw.Barcode.upcA();
      case 'pdf417':
        return bw.Barcode.pdf417();
      default:
        return bw.Barcode.code128();
    }
  }

  Future<void> _saveToGallery() async {
    setState(() => _isSaving = true);
    try {
      if (Platform.isAndroid) {
        final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
        final AndroidDeviceInfo info = await deviceInfoPlugin.androidInfo;
        if ((info.version.sdkInt) < 29) {
          final storageStatus = await Permission.storage.request();
          if (!storageStatus.isGranted && !storageStatus.isLimited) {
            if (!mounted) return;
            _showPermissionDeniedDialog();
            setState(() => _isSaving = false);
            return;
          }
        }
      }

      await Future.delayed(const Duration(milliseconds: 100));
      final boundary =
          _previewKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('Preview not ready');

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      final result = await ImageGallerySaverPlus.saveImage(
        buffer,
        quality: 100,
        name: 'qr_generator_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (!mounted) return;

      if (result['isSuccess'] == true) {
        CustomSnackBar.show(
          context: context,
          message: 'Saved to gallery!',
          isError: false,
        );
      } else {
        throw Exception(result['errorMessage'] ?? 'Failed to save');
      }
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.show(
        context: context,
        message: 'Failed to save: $e',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _shareImage() async {
    setState(() => _isSharing = true);
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final boundary =
          _previewKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('Preview not ready');

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/shared_qr.png');
      await file.writeAsBytes(buffer);

      // ignore: deprecated_member_use
      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Check out this generated code!');
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.show(
        context: context,
        message: 'Failed to share: $e',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  void _showPermissionDeniedDialog() {
    CustomSnackBar.show(
      context: context,
      message: 'Storage/Photos permission is required to save.',
      isError: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.teal, AppColors.darkTeal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.item.title ?? widget.item.format,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                RepaintBoundary(
                  key: _previewKey,
                  child: Container(
                    color: AppColors.white,
                    padding: const EdgeInsets.all(16),
                    child: widget.item.type == 'qr'
                        ? QrCornerFrame(
                            size: 240,
                            cornerLength: 32,
                            strokeWidth: 5,
                            padding: 8,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                QrImageView(
                                  data: widget.item.data,
                                  version: QrVersions.auto,
                                  errorCorrectionLevel: QrErrorCorrectLevel.H,
                                  size: 200,
                                  backgroundColor: AppColors.white,
                                  eyeStyle: const QrEyeStyle(
                                    eyeShape: QrEyeShape.square,
                                    color: AppColors.darkTeal,
                                  ),
                                  dataModuleStyle: const QrDataModuleStyle(
                                    dataModuleShape: QrDataModuleShape.square,
                                    color: AppColors.charcoal,
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.sizeOf(context).height * .05,
                                  height: MediaQuery.sizeOf(context).height * .05,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.darkTeal.withValues(
                                          alpha: 0.12,
                                        ),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: Image.asset(
                                      'assets/leos-logo.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : QrCornerFrame(
                            width: 260,
                            height: 160,
                            cornerLength: 32,
                            strokeWidth: 5,
                            padding: 12,
                            child: Center(
                              child: SizedBox(
                                height: 80,
                                child: bw.BarcodeWidget(
                                  data: widget.item.data,
                                  barcode: _getBarcodeType(widget.item.format),
                                  color: AppColors.charcoal,
                                  drawText: true,
                                  style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 13,
                                    letterSpacing: 1,
                                    color: AppColors.charcoal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                // Data display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.lightGray.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.mediumGray.withValues(alpha: 0.2),
                    ),
                  ),
                  child: SelectableText(
                    widget.item.data,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AppColors.charcoal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                // Actions (Save & Share)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: _isSharing ? null : _shareImage,
                      icon: _isSharing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.teal,
                              ),
                            )
                          : const Icon(
                              Icons.share_rounded,
                              color: AppColors.teal,
                            ),
                      label: const Text(
                        'Share',
                        style: TextStyle(color: AppColors.teal),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveToGallery,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white,
                              ),
                            )
                          : const Icon(
                              Icons.download_rounded,
                              color: AppColors.white,
                            ),
                      label: const Text('Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
