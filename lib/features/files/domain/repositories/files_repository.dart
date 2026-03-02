import '../entities/folder_entity.dart';
import '../../../qr_generator/domain/entities/generated_item_entity.dart';

abstract class FilesRepository {
  Future<List<GeneratedItemEntity>> getUserFiles({String? userId});
  Future<List<FolderEntity>> getFolders({String? userId});
  Future<FolderEntity> createFolder(FolderEntity folder);
  Future<void> deleteFolder(String id);
  Future<void> moveItemToFolder(String itemId, String category);
  Future<void> deleteItem(String itemId, String? userId);
}
