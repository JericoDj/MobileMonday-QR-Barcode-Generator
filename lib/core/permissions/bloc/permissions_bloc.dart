import 'package:flutter_bloc/flutter_bloc.dart';

import 'permissions_event.dart';
import 'permissions_state.dart';
import '../domain/usecases/request_app_permissions_usecase.dart';
import '../domain/usecases/check_app_permissions_usecase.dart';
import '../domain/entities/app_permission_status.dart';

class PermissionsBloc extends Bloc<PermissionsEvent, PermissionsState> {
  final CheckAppPermissionsUsecase checkAppPermissionsUsecase;
  final RequestAppPermissionsUsecase requestAppPermissionsUsecase;

  PermissionsBloc({
    required this.checkAppPermissionsUsecase,
    required this.requestAppPermissionsUsecase,
  }) : super(PermissionsInitial()) {
    on<CheckAppPermissions>(_onCheckAppPermissions);
    on<RequestAppPermissions>(_onRequestAppPermissions);
  }

  Future<void> _onCheckAppPermissions(
    CheckAppPermissions event,
    Emitter<PermissionsState> emit,
  ) async {
    emit(PermissionsChecking());

    final AppPermissionStatus status = await checkAppPermissionsUsecase();

    if (!status.isAllGranted) {
      emit(PermissionsRationaleRequired());
    } else {
      emit(PermissionsGranted());
    }
  }

  Future<void> _onRequestAppPermissions(
    RequestAppPermissions event,
    Emitter<PermissionsState> emit,
  ) async {
    emit(PermissionsRequesting());

    final AppPermissionStatus status = await requestAppPermissionsUsecase();

    if (!status.isAllGranted) {
      emit(
        PermissionsDenied(
          cameraDenied: status.cameraDenied,
          storageDenied: status.storageDenied,
          photosDenied: status.photosDenied,
        ),
      );
    } else {
      emit(PermissionsGranted());
    }
  }
}
