/// Type of code (QR vs Barcode).
enum CodeType { qr, barcode }

/// Specific format/version of a barcode or QR code.
enum CodeFormat {
  // QR types
  qrStandard,
  qrUrl,
  qrVcard,
  qrWifi,
  qrLocation,
  qrDeepLink,

  // Barcode types
  code128,
  code39,
  ean13,
  ean8,
  upcA,
  pdf417,
}

/// Extension to get display names and icons for formats.
extension CodeFormatExtension on CodeFormat {
  String get displayName {
    switch (this) {
      case CodeFormat.qrStandard:
        return 'Standard QR';
      case CodeFormat.qrUrl:
        return 'URL / Website';
      case CodeFormat.qrVcard:
        return 'Contact (vCard)';
      case CodeFormat.qrWifi:
        return 'Wi-Fi Share';
      case CodeFormat.qrLocation:
        return 'Location';
      case CodeFormat.qrDeepLink:
        return 'Deep Link';
      case CodeFormat.code128:
        return 'Code 128';
      case CodeFormat.code39:
        return 'Code 39';
      case CodeFormat.ean13:
        return 'EAN-13';
      case CodeFormat.ean8:
        return 'EAN-8';
      case CodeFormat.upcA:
        return 'UPC-A';
      case CodeFormat.pdf417:
        return 'PDF417';
    }
  }

  bool get isQr => name.startsWith('qr');
  bool get isBarcode => !isQr;
}
