import '../../../scanner/domain/entities/scan_entity.dart';
import '../repositories/history_repository.dart';

class GetHistoryUsecase {
  final HistoryRepository repository;
  GetHistoryUsecase(this.repository);
  Future<List<ScanEntity>> call({String? userId}) =>
      repository.getHistory(userId: userId);
}
