import '../../domain/entities/generated_item_entity.dart';

/// Generated item data model — maps between domain entity, SQLite, and Firestore.
class GeneratedItemModel extends GeneratedItemEntity {
  const GeneratedItemModel({
    required super.id,
    super.userId,
    required super.type,
    required super.format,
    super.title,
    required super.data,
    super.imagePath,
    super.embeddedImagePath,
    super.category,
    super.isFavorite,
    required super.createdAt,
    required super.updatedAt,
  });

  factory GeneratedItemModel.fromMap(Map<String, dynamic> map) {
    return GeneratedItemModel(
      id: map['id'] as String,
      userId: map['user_id'] as String?,
      type: map['type'] as String,
      format: map['format'] as String,
      title: map['title'] as String?,
      data: map['data'] as String,
      imagePath: map['image_path'] as String?,
      embeddedImagePath: map['embedded_image_path'] as String?,
      category: (map['category'] as String?) ?? 'uncategorized',
      isFavorite: (map['is_favorite'] as int?) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'format': format,
      'title': title,
      'data': data,
      'image_path': imagePath,
      'embedded_image_path': embeddedImagePath,
      'category': category,
      'is_favorite': isFavorite ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Serializes to Firestore-compatible map (snake_case string timestamps).
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'format': format,
      'title': title,
      'data': data,
      'image_path': imagePath,
      'embedded_image_path': embeddedImagePath,
      'category': category,
      'is_favorite': isFavorite,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory GeneratedItemModel.fromFirestore(
    String id,
    Map<String, dynamic> map,
  ) {
    return GeneratedItemModel(
      id: id,
      userId: map['user_id'] as String?,
      type: map['type'] as String,
      format: map['format'] as String,
      title: map['title'] as String?,
      data: map['data'] as String,
      imagePath: map['image_path'] as String?,
      embeddedImagePath: map['embedded_image_path'] as String?,
      category: (map['category'] as String?) ?? 'uncategorized',
      isFavorite: (map['is_favorite'] as bool?) ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  factory GeneratedItemModel.fromEntity(GeneratedItemEntity entity) {
    return GeneratedItemModel(
      id: entity.id,
      userId: entity.userId,
      type: entity.type,
      format: entity.format,
      title: entity.title,
      data: entity.data,
      imagePath: entity.imagePath,
      embeddedImagePath: entity.embeddedImagePath,
      category: entity.category,
      isFavorite: entity.isFavorite,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
