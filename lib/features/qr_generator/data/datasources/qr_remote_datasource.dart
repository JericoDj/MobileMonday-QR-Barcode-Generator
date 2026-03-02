import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/generated_item_model.dart';

/// Remote Firestore datasource for saving/reading generated QR & barcode items.
/// Writes to: users/{uid}/generated_items/{id}
class QrRemoteDatasource {
  final FirebaseFirestore _firestore;

  QrRemoteDatasource(this._firestore);

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _firestore.collection('users').doc(uid).collection('generated_items');

  Future<void> saveItem(GeneratedItemModel item, String uid) async {
    await _col(uid).doc(item.id).set(item.toFirestore());
  }

  Future<List<GeneratedItemModel>> getItems(String uid) async {
    final snap = await _col(uid).orderBy('created_at', descending: true).get();
    return snap.docs
        .map((d) => GeneratedItemModel.fromFirestore(d.id, d.data()))
        .toList();
  }

  Future<void> deleteItem(String id, String uid) async {
    await _col(uid).doc(id).delete();
  }

  Future<void> updateItem(GeneratedItemModel item, String uid) async {
    await _col(uid).doc(item.id).update(item.toFirestore());
  }
}
