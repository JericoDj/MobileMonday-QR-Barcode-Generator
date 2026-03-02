import 'package:equatable/equatable.dart';

abstract class PermissionsState extends Equatable {
  const PermissionsState();

  @override
  List<Object> get props => [];
}

class PermissionsInitial extends PermissionsState {}

class PermissionsChecking extends PermissionsState {}

class PermissionsRequesting extends PermissionsState {}

class PermissionsRationaleRequired extends PermissionsState {}

class PermissionsGranted extends PermissionsState {}

class PermissionsDenied extends PermissionsState {
  final bool cameraDenied;
  final bool storageDenied;
  final bool photosDenied;

  const PermissionsDenied({
    required this.cameraDenied,
    required this.storageDenied,
    required this.photosDenied,
  });

  @override
  List<Object> get props => [cameraDenied, storageDenied, photosDenied];
}
