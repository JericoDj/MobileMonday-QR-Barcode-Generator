import '../entities/scan_entity.dart';
import '../repositories/scan_repository.dart';

class SaveScanUsecase {
  final ScanRepository repository;
  SaveScanUsecase(this.repository);
  Future<void> call(ScanEntity scan) => repository.saveScan(scan);
}
