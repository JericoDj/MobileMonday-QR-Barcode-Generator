import '../entities/generated_item_entity.dart';
import '../repositories/qr_repository.dart';

class GenerateQrUsecase {
  final QrRepository repository;
  GenerateQrUsecase(this.repository);

  Future<GeneratedItemEntity> call(GeneratedItemEntity item) {
    return repository.saveGeneratedItem(item);
  }
}
