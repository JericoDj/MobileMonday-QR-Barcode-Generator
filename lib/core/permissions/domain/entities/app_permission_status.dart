import 'package:equatable/equatable.dart';

class AppPermissionStatus extends Equatable {
  final bool cameraDenied;
  final bool storageDenied;
  final bool photosDenied;

  const AppPermissionStatus({
    required this.cameraDenied,
    required this.storageDenied,
    required this.photosDenied,
  });

  bool get isAllGranted => !cameraDenied && !storageDenied && !photosDenied;

  @override
  List<Object> get props => [cameraDenied, storageDenied, photosDenied];
}
