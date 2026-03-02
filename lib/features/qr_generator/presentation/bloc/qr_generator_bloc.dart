import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/generated_item_entity.dart';
import '../../domain/usecases/generate_qr_usecase.dart';
import '../../domain/usecases/get_generated_items_usecase.dart';
import '../../domain/usecases/delete_generated_item_usecase.dart';

part 'qr_generator_event.dart';
part 'qr_generator_state.dart';

class QrGeneratorBloc extends Bloc<QrGeneratorEvent, QrGeneratorState> {
  final GenerateQrUsecase generateQrUsecase;
  final GetGeneratedItemsUsecase getGeneratedItemsUsecase;
  final DeleteGeneratedItemUsecase deleteGeneratedItemUsecase;

  QrGeneratorBloc({
    required this.generateQrUsecase,
    required this.getGeneratedItemsUsecase,
    required this.deleteGeneratedItemUsecase,
  }) : super(QrGeneratorInitial()) {
    on<GenerateItemRequested>(_onGenerate);
    on<LoadGeneratedItems>(_onLoadItems);
    on<DeleteItemRequested>(_onDeleteItem);
  }

  Future<void> _onGenerate(
    GenerateItemRequested event,
    Emitter<QrGeneratorState> emit,
  ) async {
    emit(QrGeneratorLoading());
    try {
      final item = await generateQrUsecase(event.item);
      emit(QrGeneratorSuccess(item));
      // Reload the list after generation
      add(LoadGeneratedItems());
    } catch (e) {
      emit(QrGeneratorError(e.toString()));
    }
  }

  Future<void> _onLoadItems(
    LoadGeneratedItems event,
    Emitter<QrGeneratorState> emit,
  ) async {
    emit(QrGeneratorLoading());
    try {
      final items = await getGeneratedItemsUsecase(userId: event.userId);
      emit(QrGeneratorItemsLoaded(items));
    } catch (e) {
      emit(QrGeneratorError(e.toString()));
    }
  }

  Future<void> _onDeleteItem(
    DeleteItemRequested event,
    Emitter<QrGeneratorState> emit,
  ) async {
    try {
      await deleteGeneratedItemUsecase(event.id);
      add(LoadGeneratedItems());
    } catch (e) {
      emit(QrGeneratorError(e.toString()));
    }
  }
}
