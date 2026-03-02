import '../entities/user_entity.dart';

/// Auth repository interface — domain layer contract.
abstract class AuthRepository {
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> login({required String email, required String password});
  Future<UserEntity> register({
    required String email,
    required String password,
    String? displayName,
  });
  Future<void> logout();
  Future<void> updateProfile({
    required String userId,
    String? displayName,
    String? avatarUrl,
  });
  Future<void> resetPassword({required String email});
  Future<void> updatePassword({required String newPassword});
  Future<void> deleteAccount();
}
