import '../repositories/files_repository.dart';

class DeleteFileItemUsecase {
  final FilesRepository repository;
  DeleteFileItemUsecase(this.repository);
  Future<void> call(String itemId, String? userId) =>
      repository.deleteItem(itemId, userId);
}
