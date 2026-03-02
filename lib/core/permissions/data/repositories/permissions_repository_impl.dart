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

      if (build.version.sdkInt >= 30) {
        var re = await Permission.manageExternalStorage.status;
        if (re.isGranted) {
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

      if (build.version.sdkInt >= 30) {
        var re = await Permission.manageExternalStorage.request();
        if (re.isGranted) {
          storageDenied = false;
          photosDenied =
              false; // Granted effectively for both concepts on API 30+ since we use MediaStore/manageExternalStorage
        } else {
          storageDenied = true;
          photosDenied = true;
        }
      } else {
        // SDK < 30 request legacy storage
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
