import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/scan_entity.dart';
import '../../domain/usecases/save_scan_usecase.dart';
import '../../domain/usecases/get_scan_history_usecase.dart';

part 'scanner_event.dart';
part 'scanner_state.dart';

class ScannerBloc extends Bloc<ScannerEvent, ScannerState> {
  final SaveScanUsecase saveScanUsecase;
  final GetScanHistoryUsecase getScanHistoryUsecase;

  ScannerBloc({
    required this.saveScanUsecase,
    required this.getScanHistoryUsecase,
  }) : super(ScannerInitial()) {
    on<ScanCompleted>(_onScanCompleted);
    on<LoadScanHistory>(_onLoadHistory);
  }

  Future<void> _onScanCompleted(
    ScanCompleted event,
    Emitter<ScannerState> emit,
  ) async {
    try {
      await saveScanUsecase(event.scan);
      emit(ScanSuccess(event.scan));
    } catch (e) {
      emit(ScannerError(e.toString()));
    }
  }

  Future<void> _onLoadHistory(
    LoadScanHistory event,
    Emitter<ScannerState> emit,
  ) async {
    emit(ScannerLoading());
    try {
      final history = await getScanHistoryUsecase(userId: event.userId);
      emit(ScanHistoryLoaded(history));
    } catch (e) {
      emit(ScannerError(e.toString()));
    }
  }
}
