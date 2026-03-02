import '../../domain/entities/scan_entity.dart';

class ScanModel extends ScanEntity {
  const ScanModel({
    required super.id,
    super.userId,
    required super.scannedData,
    required super.scanType,
    super.format,
    required super.timestamp,
  });

  factory ScanModel.fromMap(Map<String, dynamic> map) {
    return ScanModel(
      id: map['id'] as String,
      userId: map['user_id'] as String?,
      scannedData: map['scanned_data'] as String,
      scanType: map['scan_type'] as String,
      format: map['format'] as String?,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'scanned_data': scannedData,
      'scan_type': scanType,
      'format': format,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ScanModel.fromEntity(ScanEntity entity) {
    return ScanModel(
      id: entity.id,
      userId: entity.userId,
      scannedData: entity.scannedData,
      scanType: entity.scanType,
      format: entity.format,
      timestamp: entity.timestamp,
    );
  }
}
