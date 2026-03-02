import '../../domain/repositories/history_repository.dart';
import '../../../scanner/domain/entities/scan_entity.dart';
import '../datasources/history_local_datasource.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryLocalDatasource _localDatasource;
  HistoryRepositoryImpl(this._localDatasource);

  @override
  Future<List<ScanEntity>> getHistory({String? userId}) =>
      _localDatasource.getHistory(userId: userId);

  @override
  Future<void> clearHistory({String? userId}) =>
      _localDatasource.clearHistory(userId: userId);
}
