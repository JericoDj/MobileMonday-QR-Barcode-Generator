import '../entities/app_permission_status.dart';
import '../repositories/permissions_repository.dart';

class CheckAppPermissionsUsecase {
  final PermissionsRepository repository;

  CheckAppPermissionsUsecase(this.repository);

  Future<AppPermissionStatus> call() async {
    return await repository.checkAppPermissions();
  }
}
