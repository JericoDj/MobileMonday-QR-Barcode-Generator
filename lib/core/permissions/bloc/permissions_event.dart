import 'package:equatable/equatable.dart';

abstract class PermissionsEvent extends Equatable {
  const PermissionsEvent();

  @override
  List<Object> get props => [];
}

class CheckAppPermissions extends PermissionsEvent {
  const CheckAppPermissions();
}

class RequestAppPermissions extends PermissionsEvent {
  const RequestAppPermissions();
}
