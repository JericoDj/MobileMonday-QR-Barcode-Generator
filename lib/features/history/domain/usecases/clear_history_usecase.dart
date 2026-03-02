import '../repositories/history_repository.dart';

class ClearHistoryUsecase {
  final HistoryRepository repository;
  ClearHistoryUsecase(this.repository);
  Future<void> call({String? userId}) =>
      repository.clearHistory(userId: userId);
}
