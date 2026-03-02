import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../scanner/domain/entities/scan_entity.dart';
import '../../domain/usecases/get_history_usecase.dart';
import '../../domain/usecases/clear_history_usecase.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetHistoryUsecase getHistoryUsecase;
  final ClearHistoryUsecase clearHistoryUsecase;

  HistoryBloc({
    required this.getHistoryUsecase,
    required this.clearHistoryUsecase,
  }) : super(HistoryInitial()) {
    on<LoadHistory>(_onLoadHistory);
    on<ClearHistoryRequested>(_onClearHistory);
  }

  Future<void> _onLoadHistory(
    LoadHistory event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryLoading());
    try {
      final history = await getHistoryUsecase(userId: event.userId);
      emit(HistoryLoaded(history));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }

  Future<void> _onClearHistory(
    ClearHistoryRequested event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      await clearHistoryUsecase(userId: event.userId);
      emit(const HistoryLoaded([]));
    } catch (e) {
      emit(HistoryError(e.toString()));
    }
  }
}
