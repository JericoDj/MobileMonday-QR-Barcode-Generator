import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../qr_generator/domain/entities/generated_item_entity.dart';
import '../../domain/entities/folder_entity.dart';
import '../../domain/usecases/get_user_files_usecase.dart';
import '../../domain/usecases/create_folder_usecase.dart';
import '../../domain/usecases/delete_file_item_usecase.dart';

part 'files_event.dart';
part 'files_state.dart';

class FilesBloc extends Bloc<FilesEvent, FilesState> {
  final GetUserFilesUsecase getUserFilesUsecase;
  final CreateFolderUsecase createFolderUsecase;
  final DeleteFileItemUsecase deleteFileItemUsecase;

  FilesBloc({
    required this.getUserFilesUsecase,
    required this.createFolderUsecase,
    required this.deleteFileItemUsecase,
  }) : super(FilesInitial()) {
    on<LoadUserFiles>(_onLoadFiles);
    on<CreateFolderRequested>(_onCreateFolder);
    on<DeleteFileItemRequested>(_onDeleteItem);
  }

  Future<void> _onLoadFiles(
    LoadUserFiles event,
    Emitter<FilesState> emit,
  ) async {
    emit(FilesLoading());
    try {
      final files = await getUserFilesUsecase(userId: event.userId);
      emit(FilesLoaded(files));
    } catch (e) {
      emit(FilesError(e.toString()));
    }
  }

  Future<void> _onCreateFolder(
    CreateFolderRequested event,
    Emitter<FilesState> emit,
  ) async {
    try {
      await createFolderUsecase(event.folder);
      add(LoadUserFiles());
    } catch (e) {
      emit(FilesError(e.toString()));
    }
  }

  Future<void> _onDeleteItem(
    DeleteFileItemRequested event,
    Emitter<FilesState> emit,
  ) async {
    try {
      await deleteFileItemUsecase(event.itemId, event.userId);
      // Reload with the same userId
      add(LoadUserFiles(userId: event.userId));
    } catch (e) {
      emit(FilesError(e.toString()));
    }
  }
}
