import '../entities/app_permission_status.dart';

abstract class PermissionsRepository {
  Future<AppPermissionStatus> checkAppPermissions();
  Future<AppPermissionStatus> requestAppPermissions();
}
