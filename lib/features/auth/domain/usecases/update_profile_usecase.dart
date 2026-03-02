import '../repositories/auth_repository.dart';

class UpdateProfileUseCase {
  final AuthRepository repository;

  UpdateProfileUseCase(this.repository);

  Future<void> call({
    required String userId,
    String? displayName,
    String? avatarUrl,
  }) async {
    return repository.updateProfile(
      userId: userId,
      displayName: displayName,
      avatarUrl: avatarUrl,
    );
  }
}
