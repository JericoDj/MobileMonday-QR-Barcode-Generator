import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../../domain/entities/app_permission_status.dart';
import '../../domain/repositories/permissions_repository.dart';

class PermissionsRepositoryImpl implements PermissionsRepository {
  @override
  Future<AppPermissionStatus> checkAppPermissions() async {
    bool cameraDenied = false;
    bool storageDenied = false;
    bool photosDenied = false;

    final cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted && !cameraStatus.isLimited) {
      cameraDenied = true;
    }

    if (Platform.isAndroid) {
      AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;

      if (build.version.sdkInt >= 33) {
        var result = await Permission.photos.status;
        if (result.isGranted || result.isLimited) {
          storageDenied = false;
          photosDenied = false;
        } else {
          storageDenied = true;
          photosDenied = true;
        }
      } else if (build.version.sdkInt >= 29) {
        // For API 29-32, saving images via MediaStore does not require permissions,
        // but reading still requires READ_EXTERNAL_STORAGE represented by Permission.storage.
        var result = await Permission.storage.status;
        if (result.isGranted || result.isLimited) {
          storageDenied = false;
          photosDenied = false;
        } else {
          storageDenied = true;
          photosDenied = true;
        }
      } else {
        var result = await Permission.storage.status;
        if (result.isGranted) {
          storageDenied = false;
          photosDenied = false;
        } else {
          storageDenied = true;
          photosDenied = true;
        }
      }
    } else if (Platform.isIOS) {
      final photosStatus = await Permission.photos.status;
      if (!photosStatus.isGranted && !photosStatus.isLimited) {
        photosDenied = true;
      }
    }

    return AppPermissionStatus(
      cameraDenied: cameraDenied,
      storageDenied: storageDenied,
      photosDenied: photosDenied,
    );
  }

  @override
  Future<AppPermissionStatus> requestAppPermissions() async {
    bool cameraDenied = false;
    bool storageDenied = false;
    bool photosDenied = false;

    // Request Camera permission
    final cameraStatus = await Permission.camera.request();
    if (!cameraStatus.isGranted && !cameraStatus.isLimited) {
      cameraDenied = true;
    }

    if (Platform.isAndroid) {
      AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;

      if (build.version.sdkInt >= 33) {
        var result = await Permission.photos.request();
        if (result.isGranted || result.isLimited) {
          storageDenied = false;
          photosDenied = false;
        } else {
          storageDenied = true;
          photosDenied = true;
        }
      } else if (build.version.sdkInt >= 29) {
        var result = await Permission.storage.request();
        // Since saving does not require it, we only fail if both reading and saving fail,
        // but typically storage is requested here to cover reading.
        if (result.isGranted || result.isLimited) {
          storageDenied = false;
          photosDenied = false;
        } else {
          storageDenied = true;
          photosDenied = true;
        }
      } else {
        // SDK < 29 request legacy storage
        var result = await Permission.storage.request();
        if (result.isGranted) {
          storageDenied = false;
          photosDenied = false;
        } else {
          storageDenied = true;
          photosDenied = true;
        }
      }
    } else if (Platform.isIOS) {
      final photosStatus = await Permission.photos.request();
      if (!photosStatus.isGranted && !photosStatus.isLimited) {
        photosDenied = true;
      }
    }

    return AppPermissionStatus(
      cameraDenied: cameraDenied,
      storageDenied: storageDenied,
      photosDenied: photosDenied,
    );
  }
}
