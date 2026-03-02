import '../entities/folder_entity.dart';
import '../repositories/files_repository.dart';

class CreateFolderUsecase {
  final FilesRepository repository;
  CreateFolderUsecase(this.repository);
  Future<FolderEntity> call(FolderEntity folder) =>
      repository.createFolder(folder);
}
