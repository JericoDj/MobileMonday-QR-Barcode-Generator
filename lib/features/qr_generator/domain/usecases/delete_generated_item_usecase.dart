import '../repositories/qr_repository.dart';

class DeleteGeneratedItemUsecase {
  final QrRepository repository;
  DeleteGeneratedItemUsecase(this.repository);

  Future<void> call(String id) {
    return repository.deleteGeneratedItem(id);
  }
}
