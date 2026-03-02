import '../../domain/entities/generated_item_entity.dart';
import '../../domain/repositories/qr_repository.dart';
import '../datasources/qr_local_datasource.dart';
import '../datasources/qr_remote_datasource.dart';
import '../models/generated_item_model.dart';

class QrRepositoryImpl implements QrRepository {
  final QrLocalDatasource _localDatasource;
  final QrRemoteDatasource _remoteDatasource;

  QrRepositoryImpl(this._localDatasource, this._remoteDatasource);

  @override
  Future<GeneratedItemEntity> saveGeneratedItem(
    GeneratedItemEntity item,
  ) async {
    final model = GeneratedItemModel.fromEntity(item);
    // Always save locally
    final saved = await _localDatasource.saveItem(model);
    // If user is logged in (userId present), also save to Firestore
    if (item.userId != null && item.userId!.isNotEmpty) {
      await _remoteDatasource.saveItem(model, item.userId!);
    }
    return saved;
  }

  @override
  Future<List<GeneratedItemEntity>> getGeneratedItems({String? userId}) {
    return _localDatasource.getItems(userId: userId);
  }

  @override
  Future<void> deleteGeneratedItem(String id) {
    return _localDatasource.deleteItem(id);
  }

  @override
  Future<void> updateGeneratedItem(GeneratedItemEntity item) {
    return _localDatasource.updateItem(GeneratedItemModel.fromEntity(item));
  }

  @override
  Future<List<GeneratedItemEntity>> getItemsByCategory(String category) {
    return _localDatasource.getItemsByCategory(category);
  }

  @override
  Future<void> toggleFavorite(String id, bool isFavorite) {
    return _localDatasource.toggleFavorite(id, isFavorite);
  }
}
