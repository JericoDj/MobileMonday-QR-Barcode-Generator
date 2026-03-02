import 'package:equatable/equatable.dart';

/// Generated QR/Barcode item entity — domain layer.
class GeneratedItemEntity extends Equatable {
  const GeneratedItemEntity({
    required this.id,
    this.userId,
    required this.type,
    required this.format,
    this.title,
    required this.data,
    this.imagePath,
    this.embeddedImagePath,
    this.category = 'uncategorized',
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String? userId;
  final String type; // 'qr' or 'barcode'
  final String format; // 'qrStandard', 'code128', etc.
  final String? title;
  final String data; // The encoded content
  final String? imagePath; // Saved image path
  final String? embeddedImagePath; // Logo/image embedded in QR
  final String category;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  GeneratedItemEntity copyWith({
    String? id,
    String? userId,
    String? type,
    String? format,
    String? title,
    String? data,
    String? imagePath,
    String? embeddedImagePath,
    String? category,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GeneratedItemEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      format: format ?? this.format,
      title: title ?? this.title,
      data: data ?? this.data,
      imagePath: imagePath ?? this.imagePath,
      embeddedImagePath: embeddedImagePath ?? this.embeddedImagePath,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, type, format, data, category, isFavorite];
}
