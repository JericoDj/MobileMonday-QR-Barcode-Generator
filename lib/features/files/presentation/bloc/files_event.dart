part of 'files_bloc.dart';

abstract class FilesEvent extends Equatable {
  const FilesEvent();
  @override
  List<Object?> get props => [];
}

class LoadUserFiles extends FilesEvent {
  final String? userId;
  const LoadUserFiles({this.userId});
  @override
  List<Object?> get props => [userId];
}

class CreateFolderRequested extends FilesEvent {
  final FolderEntity folder;
  const CreateFolderRequested(this.folder);
  @override
  List<Object?> get props => [folder];
}

class DeleteFileItemRequested extends FilesEvent {
  final String itemId;
  final String? userId;
  const DeleteFileItemRequested({required this.itemId, this.userId});
  @override
  List<Object?> get props => [itemId, userId];
}
