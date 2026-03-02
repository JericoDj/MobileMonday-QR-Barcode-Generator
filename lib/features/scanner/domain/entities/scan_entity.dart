import 'package:equatable/equatable.dart';

/// Scan history entity — domain layer.
class ScanEntity extends Equatable {
  const ScanEntity({
    required this.id,
    this.userId,
    required this.scannedData,
    required this.scanType,
    this.format,
    required this.timestamp,
  });

  final String id;
  final String? userId;
  final String scannedData;
  final String scanType; // 'qr' or 'barcode'
  final String? format;
  final DateTime timestamp;

  @override
  List<Object?> get props => [id, scannedData, scanType, timestamp];
}
