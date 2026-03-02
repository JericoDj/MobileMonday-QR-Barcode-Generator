part of 'qr_generator_bloc.dart';

abstract class QrGeneratorState extends Equatable {
  const QrGeneratorState();
  @override
  List<Object?> get props => [];
}

class QrGeneratorInitial extends QrGeneratorState {}

class QrGeneratorLoading extends QrGeneratorState {}

class QrGeneratorSuccess extends QrGeneratorState {
  final GeneratedItemEntity item;
  const QrGeneratorSuccess(this.item);
  @override
  List<Object?> get props => [item];
}

class QrGeneratorItemsLoaded extends QrGeneratorState {
  final List<GeneratedItemEntity> items;
  const QrGeneratorItemsLoaded(this.items);
  @override
  List<Object?> get props => [items];
}

class QrGeneratorError extends QrGeneratorState {
  final String message;
  const QrGeneratorError(this.message);
  @override
  List<Object?> get props => [message];
}
