import '../entities/generated_item_entity.dart';

/// QR/Barcode repository interface — domain layer.
abstract class QrRepository {
  Future<GeneratedItemEntity> saveGeneratedItem(GeneratedItemEntity item);
  Future<List<GeneratedItemEntity>> getGeneratedItems({String? userId});
  Future<void> deleteGeneratedItem(String id);
  Future<void> updateGeneratedItem(GeneratedItemEntity item);
  Future<List<GeneratedItemEntity>> getItemsByCategory(String category);
  Future<void> toggleFavorite(String id, bool isFavorite);
}
