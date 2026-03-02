import '../../../../core/database/database_helper.dart';
import '../models/generated_item_model.dart';

/// Local datasource for QR/barcode generated items.
class QrLocalDatasource {
  final DatabaseHelper _dbHelper;
  QrLocalDatasource(this._dbHelper);

  Future<GeneratedItemModel> saveItem(GeneratedItemModel item) async {
    final db = await _dbHelper.database;
    await db.insert('generated_items', item.toMap());
    return item;
  }

  Future<List<GeneratedItemModel>> getItems({String? userId}) async {
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

  Future<void> deleteItem(String id) async {
    final db = await _dbHelper.database;
    await db.delete('generated_items', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateItem(GeneratedItemModel item) async {
    final db = await _dbHelper.database;
    await db.update(
      'generated_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<List<GeneratedItemModel>> getItemsByCategory(String category) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      'generated_items',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'created_at DESC',
    );
    return results.map((m) => GeneratedItemModel.fromMap(m)).toList();
  }

  Future<void> toggleFavorite(String id, bool isFavorite) async {
    final db = await _dbHelper.database;
    await db.update(
      'generated_items',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
