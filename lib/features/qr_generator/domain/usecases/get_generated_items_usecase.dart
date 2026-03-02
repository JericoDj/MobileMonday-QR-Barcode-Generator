import '../entities/generated_item_entity.dart';
import '../repositories/qr_repository.dart';

class GetGeneratedItemsUsecase {
  final QrRepository repository;
  GetGeneratedItemsUsecase(this.repository);

  Future<List<GeneratedItemEntity>> call({String? userId}) {
    return repository.getGeneratedItems(userId: userId);
  }
}
