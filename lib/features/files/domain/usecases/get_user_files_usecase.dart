import '../../../qr_generator/domain/entities/generated_item_entity.dart';
import '../repositories/files_repository.dart';

class GetUserFilesUsecase {
  final FilesRepository repository;
  GetUserFilesUsecase(this.repository);
  Future<List<GeneratedItemEntity>> call({String? userId}) =>
      repository.getUserFiles(userId: userId);
}
