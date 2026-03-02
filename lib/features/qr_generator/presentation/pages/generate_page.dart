import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../domain/entities/generated_item_entity.dart';
import '../bloc/qr_generator_bloc.dart';
import 'package:barcode_widget/barcode_widget.dart' as bw;
import '../widgets/generator_tab_bar.dart';
import '../widgets/generator_input_section.dart';
import '../widgets/qr_preview_card.dart';

/// Generate page — QR codes & barcodes with validation and hints.
class GeneratePage extends StatefulWidget {
  const GeneratePage({super.key});

  @override
  State<GeneratePage> createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _dataController = TextEditingController();
  final _titleController = TextEditingController();
  String _selectedFormat = 'qrStandard';
  String? _generatedData;
  String? _validationError;
  GlobalKey _previewKey = GlobalKey();
  bool _isSaving = false;
  bool _isSharing = false;

  // ─── QR Formats ──────────────────────────────────
  final _qrFormats = [
    {
      'key': 'qrStandard',
      'label': 'Standard',
      'icon': Icons.qr_code_rounded,
      'hint': 'Any text, URL, or data',
      'placeholder': 'Enter text to encode',
      'help':
          'Standard QR\n\n'
          '• Accepts any text, numbers, or symbols\n'
          '• Max ~4,296 characters\n'
          '• Best for general-purpose encoding',
    },
    {
      'key': 'qrUrl',
      'label': 'URL',
      'icon': Icons.link_rounded,
      'hint': 'Website URL (include https://)',
      'placeholder': 'https://example.com',
      'help':
          'URL / Website QR\n\n'
          '• Must start with http:// or https://\n'
          '• When scanned, opens the browser\n'
          '• Example: https://flutter.dev',
    },
    {
      'key': 'qrVcard',
      'label': 'vCard',
      'icon': Icons.contact_page_rounded,
      'hint': 'Contact info in vCard format',
      'placeholder':
          'BEGIN:VCARD\nVERSION:3.0\nN:Doe;John\nTEL:+1234567890\nEND:VCARD',
      'help':
          'Contact (vCard) QR\n\n'
          '• Encodes contact details\n'
          '• Start with BEGIN:VCARD\n'
          '• Include N: (name), TEL: (phone)\n'
          '• End with END:VCARD',
    },
    {
      'key': 'qrWifi',
      'label': 'Wi-Fi',
      'icon': Icons.wifi_rounded,
      'hint': 'Wi-Fi network details',
      'placeholder': 'WIFI:S:NetworkName;T:WPA;P:password;;',
      'help':
          'Wi-Fi Share QR\n\n'
          '• Format: WIFI:S:<SSID>;T:<WPA|WEP|nopass>;P:<password>;;\n'
          '• S = Network name (SSID)\n'
          '• T = Security type\n'
          '• P = Password\n'
          '• When scanned, auto-connects to Wi-Fi',
    },
    {
      'key': 'qrLocation',
      'label': 'Location',
      'icon': Icons.location_on_rounded,
      'hint': 'Geo coordinates (lat, long)',
      'placeholder': 'geo:37.7749,-122.4194',
      'help':
          'Location QR\n\n'
          '• Format: geo:<latitude>,<longitude>\n'
          '• Latitude: -90 to 90\n'
          '• Longitude: -180 to 180\n'
          '• When scanned, opens maps app',
    },
    {
      'key': 'qrDeepLink',
      'label': 'Deep Link',
      'icon': Icons.open_in_new_rounded,
      'hint': 'App deep link URL',
      'placeholder': 'myapp://screen/123',
      'help':
          'Deep Link QR\n\n'
          '• Custom URL scheme for mobile apps\n'
          '• Format: <scheme>://<path>\n'
          '• When scanned, opens target app\n'
          '• Example: myapp://product/42',
    },
  ];

  // ─── Barcode Formats ─────────────────────────────
  final _barcodeFormats = [
    {
      'key': 'code128',
      'label': 'Code 128',
      'icon': Icons.view_week_rounded,
      'hint': 'Any ASCII text or numbers',
      'placeholder': 'ABC-123',
      'help':
          'Code 128\n\n'
          '• Supports all ASCII characters (A-Z, a-z, 0-9, symbols)\n'
          '• Variable length — no digit limit\n'
          '• Most versatile barcode format',
      'keyboard': TextInputType.text,
    },
    {
      'key': 'code39',
      'label': 'Code 39',
      'icon': Icons.view_week_rounded,
      'hint': 'Uppercase A-Z, 0-9, and - . \$ / + % SPACE',
      'placeholder': 'HELLO-123',
      'help':
          'Code 39\n\n'
          '• Allowed: A-Z (uppercase), 0-9\n'
          '• Special chars: - . \$ / + % SPACE\n'
          '• Variable length\n'
          '• Commonly used in non-retail environments',
      'keyboard': TextInputType.text,
    },
    {
      'key': 'ean13',
      'label': 'EAN-13',
      'icon': Icons.view_week_rounded,
      'hint': 'Enter 12 or 13 digits (check digit auto-calculated)',
      'placeholder': '5901234123457',
      'help':
          'EAN-13\n\n'
          '• Exactly 12 or 13 numeric digits\n'
          '• If 12 digits: check digit auto-added\n'
          '• If 13 digits: last digit must be valid check digit\n'
          '• Used for retail products worldwide\n'
          '• Example: 5901234123457',
      'keyboard': TextInputType.number,
      'maxLength': 13,
    },
    {
      'key': 'ean8',
      'label': 'EAN-8',
      'icon': Icons.view_week_rounded,
      'hint': 'Enter 7 or 8 digits (check digit auto-calculated)',
      'placeholder': '96385074',
      'help':
          'EAN-8\n\n'
          '• Exactly 7 or 8 numeric digits\n'
          '• If 7 digits: check digit auto-added\n'
          '• If 8 digits: last digit must be valid check digit\n'
          '• Compact version of EAN-13\n'
          '• Example: 96385074',
      'keyboard': TextInputType.number,
      'maxLength': 8,
    },
    {
      'key': 'upcA',
      'label': 'UPC-A',
      'icon': Icons.view_week_rounded,
      'hint': 'Enter 11 or 12 digits (check digit auto-calculated)',
      'placeholder': '036000291452',
      'help':
          'UPC-A\n\n'
          '• Exactly 11 or 12 numeric digits\n'
          '• If 11 digits: check digit auto-added\n'
          '• If 12 digits: last digit must be valid check digit\n'
          '• Used for retail in North America\n'
          '• Example: 036000291452',
      'keyboard': TextInputType.number,
      'maxLength': 12,
    },
    {
      'key': 'pdf417',
      'label': 'PDF417',
      'icon': Icons.view_week_rounded,
      'hint': 'Any text data (letters, numbers, symbols)',
      'placeholder': 'Any text data here',
      'help':
          'PDF417\n\n'
          '• 2D barcode that stores large data\n'
          '• Supports text, numbers, and binary\n'
          '• Up to ~1,800 ASCII characters\n'
          '• Used in IDs, boarding passes, shipping',
      'keyboard': TextInputType.text,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _dataController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _dataController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  bool get _isQr => _selectedFormat.startsWith('qr');

  Map<String, dynamic> get _currentFormatInfo {
    final formats = _isQr ? _qrFormats : _barcodeFormats;
    return formats.firstWhere(
      (f) => f['key'] == _selectedFormat,
      orElse: () => formats.first,
    );
  }

  // ─── Validation ───────────────────────────────────
  void _validateInput() {
    final text = _dataController.text;
    if (text.isEmpty) {
      setState(() => _validationError = null);
      return;
    }

    String? error;
    switch (_selectedFormat) {
      case 'qrUrl':
        if (!text.startsWith('http://') && !text.startsWith('https://')) {
          error = 'URL must start with http:// or https://';
        }
        break;
      case 'qrLocation':
        if (!text.startsWith('geo:')) {
          error = 'Must start with geo: (e.g., geo:37.77,-122.41)';
        }
        break;
      case 'qrWifi':
        if (!text.startsWith('WIFI:')) {
          error = 'Must start with WIFI: (e.g., WIFI:S:Name;T:WPA;P:pass;;)';
        }
        break;
      case 'qrVcard':
        if (!text.toUpperCase().startsWith('BEGIN:VCARD')) {
          error = 'Must start with BEGIN:VCARD';
        }
        break;
      case 'code39':
        final code39Regex = RegExp(r'^[A-Z0-9\-\.\$\/\+\%\s]+$');
        if (!code39Regex.hasMatch(text.toUpperCase())) {
          error = 'Only uppercase A-Z, 0-9, and - . \$ / + % SPACE';
        }
        break;
      case 'ean13':
        if (!RegExp(r'^\d+$').hasMatch(text)) {
          error = 'Only numeric digits allowed';
        } else if (text.length < 12 || text.length > 13) {
          error = 'Requires exactly 12 or 13 digits (${text.length} entered)';
        } else if (text.length == 13) {
          final expected = _calculateEanCheckDigit(text.substring(0, 12));
          if (text[12] != expected.toString()) {
            error = 'Invalid check digit: last digit should be "$expected"';
          }
        }
        break;
      case 'ean8':
        if (!RegExp(r'^\d+$').hasMatch(text)) {
          error = 'Only numeric digits allowed';
        } else if (text.length < 7 || text.length > 8) {
          error = 'Requires exactly 7 or 8 digits (${text.length} entered)';
        } else if (text.length == 8) {
          final expected = _calculateEanCheckDigit(text.substring(0, 7));
          if (text[7] != expected.toString()) {
            error = 'Invalid check digit: last digit should be "$expected"';
          }
        }
        break;
      case 'upcA':
        if (!RegExp(r'^\d+$').hasMatch(text)) {
          error = 'Only numeric digits allowed';
        } else if (text.length < 11 || text.length > 12) {
          error = 'Requires exactly 11 or 12 digits (${text.length} entered)';
        } else if (text.length == 12) {
          final expected = _calculateEanCheckDigit(text.substring(0, 11));
          if (text[11] != expected.toString()) {
            error = 'Invalid check digit: last digit should be "$expected"';
          }
        }
        break;
    }

    setState(() => _validationError = error);
  }

  /// Standard EAN/UPC check digit: works for EAN-8 (7 digits), EAN-13 (12 digits), UPC-A (11 digits).
  int _calculateEanCheckDigit(String digits) {
    int sum = 0;
    final isEven = digits.length.isEven;
    for (int i = 0; i < digits.length; i++) {
      final d = int.parse(digits[i]);
      // For EAN-13 (12 digits, even length): odd positions ×1, even positions ×3
      // For EAN-8 (7 digits, odd length): odd positions ×3, even positions ×1
      // For UPC-A (11 digits, odd length): odd positions ×3, even positions ×1
      final weight = (i.isEven == isEven) ? 1 : 3;
      sum += d * weight;
    }
    final remainder = sum % 10;
    return remainder == 0 ? 0 : 10 - remainder;
  }

  void _generate() {
    if (_dataController.text.isEmpty) return;
    if (_validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_validationError!),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    // Attach the current user's UID so it syncs to Firestore
    final authState = context.read<AuthBloc>().state;
    final String? userId = authState is AuthAuthenticated
        ? authState.user.id
        : null;

    final now = DateTime.now();
    final item = GeneratedItemEntity(
      id: const Uuid().v4(),
      userId: userId,
      type: _isQr ? 'qr' : 'barcode',
      format: _selectedFormat,
      title: _titleController.text.isNotEmpty ? _titleController.text : null,
      data: _dataController.text,
      createdAt: now,
      updatedAt: now,
    );

    context.read<QrGeneratorBloc>().add(GenerateItemRequested(item));
    setState(() => _generatedData = _dataController.text);
  }

  void _showFormatHelp() {
    final info = _currentFormatInfo;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(info['icon'] as IconData, color: AppColors.forest),
            const SizedBox(width: 8),
            Expanded(child: Text(info['label'] as String)),
          ],
        ),
        content: Text(
          info['help'] as String,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            height: 1.6,
            color: AppColors.charcoal,
          ),
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
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
      child: SafeArea(
        child: Column(
          children: [
            // ─── Tab Bar (QR / Barcode) ────────────────────
            GeneratorTabBar(
              controller: _tabController,
              onTap: (index) {
                setState(() {
                  _selectedFormat = index == 0 ? 'qrStandard' : 'code128';
                  _generatedData = null;
                  _validationError = null;
                  _dataController.clear();
                  _previewKey = GlobalKey();
                });
              },
            ),

            const SizedBox(height: 16),

            // ─── Content ───────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildGeneratorContent(_qrFormats, true),
                  _buildGeneratorContent(_barcodeFormats, false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneratorContent(List<Map<String, dynamic>> formats, bool isQr) {
    final info = _currentFormatInfo;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Format Selector + Help Button ──────────
          Row(
            children: [
              Expanded(
                child: Text(
                  isQr ? 'QR Type' : 'Barcode Format',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              // Help button
              GestureDetector(
                onTap: _showFormatHelp,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.amber.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.help_outline_rounded,
                        size: 16,
                        color: AppColors.amber,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'How to use',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: formats.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final fmt = formats[index];
                final isSelected = _selectedFormat == fmt['key'];
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedFormat = fmt['key'] as String;
                    _generatedData = null;
                    _validationError = null;
                    _dataController.clear();
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 90,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.forest.withValues(alpha: 0.1)
                          : AppColors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.forest
                            : AppColors.lightGray,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          fmt['icon'] as IconData,
                          size: 24,
                          color: isSelected
                              ? AppColors.forest
                              : AppColors.mediumGray,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          fmt['label'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: isSelected
                                ? AppColors.forest
                                : AppColors.darkGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // ─── Format Hint Banner ───────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.forest.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.sage.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: AppColors.sage,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    info['hint'] as String,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppColors.sage,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ─── Title/Data Input ────────────────────────
          BlocConsumer<QrGeneratorBloc, QrGeneratorState>(
            listener: (context, state) {
              if (state is QrGeneratorSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Generated successfully!'),
                    backgroundColor: AppColors.forest,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              } else if (state is QrGeneratorError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              return GeneratorInputSection(
                isQr: isQr,
                info: info,
                titleController: _titleController,
                dataController: _dataController,
                validationError: _validationError,
                isLoading: state is QrGeneratorLoading,
                onClear: () {
                  _dataController.clear();
                  setState(() {
                    _generatedData = null;
                    _validationError = null;
                  });
                },
                onGenerate: _generate,
                inputFormatters: _getInputFormatters(),
              );
            },
          ),

          const SizedBox(height: 24),

          // ─── Preview ─────────────────────────────────
          if (_generatedData != null && _generatedData!.isNotEmpty)
            QrPreviewCard(
              previewKey: _previewKey,
              isQr: isQr,
              generatedData: _generatedData!,
              barcodeType: _getBarcodeType(),
              isSharing: _isSharing,
              isSaving: _isSaving,
              onShare: _shareImage,
              onSave: _saveToGallery,
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── Capture / Save / Share ──────────────────────
  Future<Uint8List?> _capturePreviewImage() async {
    try {
      final boundary =
          _previewKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Capture error: $e');
      return null;
    }
  }

  Future<void> _saveToGallery() async {
    setState(() => _isSaving = true);
    try {
      // Check and request permissions
      bool hasPermission = false;

      if (Platform.isAndroid) {
        var photosStatus = await Permission.photos.request();
        if (photosStatus.isGranted || photosStatus.isLimited) {
          hasPermission = true;
        } else {
          var storageStatus = await Permission.storage.request();
          if (storageStatus.isGranted || storageStatus.isLimited) {
            hasPermission = true;
          } else if (photosStatus.isPermanentlyDenied &&
              storageStatus.isPermanentlyDenied) {
            _showPermissionDeniedDialog();
            return;
          } else if (photosStatus.isDenied &&
              storageStatus.isPermanentlyDenied) {
            // Often on Android 13+, storage is permanently denied, but photos is just denied or not asked.
            // We should let it pass if we can, but we need one of them.
          }
        }
      } else {
        var photosStatus = await Permission.photos.request();
        if (photosStatus.isGranted || photosStatus.isLimited) {
          hasPermission = true;
        } else if (photosStatus.isPermanentlyDenied) {
          _showPermissionDeniedDialog();
          return;
        }
      }

      if (!hasPermission) {
        if (mounted) {
          CustomSnackBar.show(
            context: context,
            message: 'Permission is required to save images',
            isError: true,
          );
        }
        return;
      }

      final bytes = await _capturePreviewImage();
      if (bytes == null) {
        if (mounted) {
          CustomSnackBar.show(
            context: context,
            message: 'Failed to capture image',
            isError: true,
          );
        }
        return;
      }

      final result = await ImageGallerySaverPlus.saveImage(
        bytes,
        quality: 100,
        name: 'QR_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (mounted) {
        final success = result['isSuccess'] == true;
        CustomSnackBar.show(
          context: context,
          message: success ? 'Saved to photo gallery!' : 'Failed to save',
          isError: !success,
        );
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.show(
          context: context,
          message: 'Error saving: $e',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showPermissionDeniedDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            SizedBox(width: 8),
            Text('Permission Required'),
          ],
        ),
        content: const Text(
          'Storage or Photos permission is permanently denied. Please enable it in app settings to save generated images.',
          style: TextStyle(
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
              backgroundColor: AppColors.forest,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _shareImage() async {
    setState(() => _isSharing = true);
    try {
      final bytes = await _capturePreviewImage();
      if (bytes == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to capture image'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
        return;
      }

      // Write to a temp file for sharing
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/qr_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes);

      // Open native share sheet
      final title = _titleController.text.isNotEmpty
          ? _titleController.text
          : (_isQr ? 'QR Code' : 'Barcode');

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          title: title,
          text:
              'Check out this ${_isQr ? "QR code" : "barcode"}: $_generatedData',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  List<TextInputFormatter> _getInputFormatters() {
    switch (_selectedFormat) {
      case 'ean13':
      case 'ean8':
      case 'upcA':
        return [FilteringTextInputFormatter.digitsOnly];
      case 'code39':
        return [
          FilteringTextInputFormatter.allow(
            RegExp(r'[A-Za-z0-9\-\.\$\/\+\%\s]'),
          ),
          TextInputFormatter.withFunction((oldValue, newValue) {
            return newValue.copyWith(text: newValue.text.toUpperCase());
          }),
        ];
      default:
        return [];
    }
  }

  bw.Barcode _getBarcodeType() {
    switch (_selectedFormat) {
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
}
