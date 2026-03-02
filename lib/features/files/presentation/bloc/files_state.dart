part of 'files_bloc.dart';

abstract class FilesState extends Equatable {
  const FilesState();
  @override
  List<Object?> get props => [];
}

class FilesInitial extends FilesState {}

class FilesLoading extends FilesState {}

class FilesLoaded extends FilesState {
  final List<GeneratedItemEntity> files;
  const FilesLoaded(this.files);
  @override
  List<Object?> get props => [files];
}

class FilesError extends FilesState {
  final String message;
  const FilesError(this.message);
  @override
  List<Object?> get props => [message];
}
