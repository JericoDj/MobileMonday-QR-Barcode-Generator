import '../../../../core/database/database_helper.dart';
import '../../../scanner/data/models/scan_model.dart';

class HistoryLocalDatasource {
  final DatabaseHelper _dbHelper;
  HistoryLocalDatasource(this._dbHelper);

  Future<List<ScanModel>> getHistory({String? userId}) async {
    final db = await _dbHelper.database;
    List<Map<String, dynamic>> results;
    if (userId != null) {
      results = await db.query(
        'scan_history',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'timestamp DESC',
      );
    } else {
      results = await db.query('scan_history', orderBy: 'timestamp DESC');
    }
    return results.map((m) => ScanModel.fromMap(m)).toList();
  }

  Future<void> clearHistory({String? userId}) async {
    final db = await _dbHelper.database;
    if (userId != null) {
      await db.delete(
        'scan_history',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    } else {
      await db.delete('scan_history');
    }
  }
}
