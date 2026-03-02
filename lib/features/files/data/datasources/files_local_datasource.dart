import '../../../../core/database/database_helper.dart';
import '../../../qr_generator/data/models/generated_item_model.dart';
import '../models/folder_model.dart';

class FilesLocalDatasource {
  final DatabaseHelper _dbHelper;
  FilesLocalDatasource(this._dbHelper);

  Future<List<GeneratedItemModel>> getUserFiles({String? userId}) async {
    final db = await _dbHelper.database;
    List<Map<String, dynamic>> results;
    if (userId != null) {
      results = await db.query(
        'generated_items',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );
    } else {
      results = await db.query('generated_items', orderBy: 'created_at DESC');
    }
    return results.map((m) => GeneratedItemModel.fromMap(m)).toList();
  }

  Future<List<FolderModel>> getFolders({String? userId}) async {
    final db = await _dbHelper.database;
    List<Map<String, dynamic>> results;
    if (userId != null) {
      results = await db.query(
        'folders',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );
    } else {
      results = await db.query('folders', orderBy: 'created_at DESC');
    }
    return results.map((m) => FolderModel.fromMap(m)).toList();
  }

  Future<FolderModel> createFolder(FolderModel folder) async {
    final db = await _dbHelper.database;
    await db.insert('folders', folder.toMap());
    return folder;
  }

  Future<void> deleteFolder(String id) async {
    final db = await _dbHelper.database;
    await db.delete('folders', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> moveItemToFolder(String itemId, String category) async {
    final db = await _dbHelper.database;
    await db.update(
      'generated_items',
      {'category': category},
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  Future<void> deleteItem(String id) async {
    final db = await _dbHelper.database;
    await db.delete('generated_items', where: 'id = ?', whereArgs: [id]);
  }
}
