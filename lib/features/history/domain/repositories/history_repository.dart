import '../../../scanner/domain/entities/scan_entity.dart';

abstract class HistoryRepository {
  Future<List<ScanEntity>> getHistory({String? userId});
  Future<void> clearHistory({String? userId});
}
