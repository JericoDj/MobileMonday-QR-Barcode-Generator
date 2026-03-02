import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Auth repository implementation — delegates to remote (Firebase) datasource.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;

  AuthRepositoryImpl(this._remoteDatasource);

  @override
  Future<UserEntity?> getCurrentUser() => _remoteDatasource.getCurrentUser();

  @override
  Future<UserEntity> login({required String email, required String password}) =>
      _remoteDatasource.login(email: email, password: password);

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    String? displayName,
  }) => _remoteDatasource.register(
    email: email,
    password: password,
    displayName: displayName,
  );

  @override
  Future<void> logout() => _remoteDatasource.logout();

  @override
  Future<void> updateProfile({
    required String userId,
    String? displayName,
    String? avatarUrl,
  }) => _remoteDatasource.updateProfile(
    userId: userId,
    displayName: displayName,
    avatarUrl: avatarUrl,
  );

  @override
  Future<void> resetPassword({required String email}) =>
      _remoteDatasource.resetPassword(email: email);

  @override
  Future<void> updatePassword({required String newPassword}) =>
      _remoteDatasource.updatePassword(newPassword: newPassword);

  @override
  Future<void> deleteAccount() => _remoteDatasource.deleteAccount();
}
