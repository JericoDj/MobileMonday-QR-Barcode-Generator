import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/folder_entity.dart';
import '../../domain/repositories/files_repository.dart';
import '../../../qr_generator/domain/entities/generated_item_entity.dart';
import '../datasources/files_local_datasource.dart';
import '../datasources/files_remote_datasource.dart';
import '../models/folder_model.dart';

class FilesRepositoryImpl implements FilesRepository {
  final FilesLocalDatasource _localDatasource;
  final FilesRemoteDatasource _remoteDatasource;
  final FirebaseAuth _auth;

  FilesRepositoryImpl(
    this._localDatasource,
    this._remoteDatasource,
    this._auth,
  );

  bool get _isLoggedIn => _auth.currentUser != null;
  String? get _uid => _auth.currentUser?.uid;

  @override
  Future<List<GeneratedItemEntity>> getUserFiles({String? userId}) async {
    final uid = userId ?? _uid;
    if (_isLoggedIn && uid != null) {
      try {
        return await _remoteDatasource.getUserFiles(userId: uid);
      } catch (e) {
        return _localDatasource.getUserFiles(userId: uid);
      }
    }
    return _localDatasource.getUserFiles(userId: userId);
  }

  @override
  Future<List<FolderEntity>> getFolders({String? userId}) async {
    if (_isLoggedIn) {
      try {
        return await _remoteDatasource.getFolders(userId: userId);
      } catch (e) {
        return _localDatasource.getFolders(userId: userId);
      }
    }
    return _localDatasource.getFolders(userId: userId);
  }

  @override
  Future<FolderEntity> createFolder(FolderEntity folder) async {
    final folderModel = FolderModel.fromEntity(folder);
    if (_isLoggedIn) {
      try {
        await _remoteDatasource.createFolder(folderModel);
      } catch (_) {}
    }
    return _localDatasource.createFolder(folderModel);
  }

  @override
  Future<void> deleteFolder(String id) async {
    if (_isLoggedIn) {
      try {
        await _remoteDatasource.deleteFolder(id);
      } catch (_) {}
    }
    await _localDatasource.deleteFolder(id);
  }

  @override
  Future<void> moveItemToFolder(String itemId, String category) async {
    if (_isLoggedIn) {
      try {
        await _remoteDatasource.moveItemToFolder(itemId, category);
      } catch (_) {}
    }
    await _localDatasource.moveItemToFolder(itemId, category);
  }

  @override
  Future<void> deleteItem(String itemId, String? userId) async {
    final uid = userId ?? _uid;
    if (_isLoggedIn && uid != null) {
      try {
        await _remoteDatasource.deleteItem(itemId, uid);
      } catch (_) {}
    }
    // Also remove from local SQLite if it exists
    try {
      await _localDatasource.deleteItem(itemId);
    } catch (_) {}
  }
}
