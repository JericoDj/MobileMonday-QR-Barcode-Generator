import '../repositories/auth_repository.dart';

class UpdatePasswordUseCase {
  final AuthRepository repository;

  UpdatePasswordUseCase(this.repository);

  Future<void> call({required String newPassword}) async {
    return repository.updatePassword(newPassword: newPassword);
  }
}
