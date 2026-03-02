import '../entities/scan_entity.dart';
import '../repositories/scan_repository.dart';

class GetScanHistoryUsecase {
  final ScanRepository repository;
  GetScanHistoryUsecase(this.repository);
  Future<List<ScanEntity>> call({String? userId}) =>
      repository.getScanHistory(userId: userId);
}
