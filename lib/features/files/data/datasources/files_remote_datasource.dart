import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../qr_generator/data/models/generated_item_model.dart';
import '../models/folder_model.dart';

class FilesRemoteDatasource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  FilesRemoteDatasource(this._firestore, this._storage, this._auth);

  String? get _userId => _auth.currentUser?.uid;

  Future<List<GeneratedItemModel>> getUserFiles({String? userId}) async {
    final uid = userId ?? _userId;
    if (uid == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('generated_items')
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => GeneratedItemModel.fromFirestore(doc.id, doc.data()))
        .toList();
  }

  Future<List<FolderModel>> getFolders({String? userId}) async {
    final uid = userId ?? _userId;
    if (uid == null) return [];

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('folders')
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs.map((doc) => FolderModel.fromMap(doc.data())).toList();
  }

  Future<FolderModel> createFolder(FolderModel folder) async {
    final uid = folder.userId ?? _userId;
    if (uid == null) throw Exception('User not logged in');

    final finalFolder = folder.copyWith(userId: uid);
    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('folders')
        .doc(finalFolder.id);
    await docRef.set(finalFolder.toMap());

    return finalFolder;
  }

  Future<void> deleteFolder(String id) async {
    final uid = _userId;
    if (uid == null) throw Exception('User not logged in');

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('folders')
        .doc(id)
        .delete();
  }

  Future<void> moveItemToFolder(String itemId, String category) async {
    final uid = _userId;
    if (uid == null) throw Exception('User not logged in');

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('files')
        .doc(itemId)
        .update({'category': category});
  }

  Future<String?> uploadFileImage(String itemId, File imageFile) async {
    final uid = _userId;
    if (uid == null) return null;

    try {
      final ref = _storage.ref().child('users/$uid/files/$itemId.png');
      final uploadTask = await ref.putFile(imageFile);
      final url = await uploadTask.ref.getDownloadURL();

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('generated_items')
          .doc(itemId)
          .update({'image_path': url});

      return url;
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteItem(String itemId, String uid) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('generated_items')
        .doc(itemId)
        .delete();
  }
}
