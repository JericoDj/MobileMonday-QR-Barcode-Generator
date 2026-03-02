part of 'qr_generator_bloc.dart';

abstract class QrGeneratorEvent extends Equatable {
  const QrGeneratorEvent();
  @override
  List<Object?> get props => [];
}

class GenerateItemRequested extends QrGeneratorEvent {
  final GeneratedItemEntity item;
  const GenerateItemRequested(this.item);
  @override
  List<Object?> get props => [item];
}

class LoadGeneratedItems extends QrGeneratorEvent {
  final String? userId;
  const LoadGeneratedItems({this.userId});
  @override
  List<Object?> get props => [userId];
}

class DeleteItemRequested extends QrGeneratorEvent {
  final String id;
  const DeleteItemRequested(this.id);
  @override
  List<Object?> get props => [id];
}
