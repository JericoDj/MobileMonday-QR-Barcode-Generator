import '../entities/app_permission_status.dart';
import '../repositories/permissions_repository.dart';

class RequestAppPermissionsUsecase {
  final PermissionsRepository repository;

  RequestAppPermissionsUsecase(this.repository);

  Future<AppPermissionStatus> call() async {
    return await repository.requestAppPermissions();
  }
}
