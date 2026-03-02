import '../../domain/entities/scan_entity.dart';
import '../../domain/repositories/scan_repository.dart';
import '../datasources/scan_local_datasource.dart';
import '../models/scan_model.dart';

class ScanRepositoryImpl implements ScanRepository {
  final ScanLocalDatasource _localDatasource;
  ScanRepositoryImpl(this._localDatasource);

  @override
  Future<void> saveScan(ScanEntity scan) =>
      _localDatasource.saveScan(ScanModel.fromEntity(scan));

  @override
  Future<List<ScanEntity>> getScanHistory({String? userId}) =>
      _localDatasource.getScanHistory(userId: userId);

  @override
  Future<void> clearHistory({String? userId}) =>
      _localDatasource.clearHistory(userId: userId);
}
