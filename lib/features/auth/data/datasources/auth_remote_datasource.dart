import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Remote datasource for auth — uses Firebase Auth + Cloud Firestore.
class AuthRemoteDatasource {
  final auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDatasource(this._firebaseAuth, this._firestore);

  /// Get the currently logged-in user from Firebase.
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    final docInfo = await _firestore.collection('users').doc(user.uid).get();

    if (docInfo.exists && docInfo.data() != null) {
      return UserModel.fromMap(docInfo.data()!);
    } else {
      // Create basic model if missing from Firestore
      final defaultModel = UserModel(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        avatarUrl: user.photoURL,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(defaultModel.toMap());
      return defaultModel;
    }
  }

  /// Register a new user with Firebase Auth.
  Future<UserModel> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credentials = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credentials.user;
    if (user == null) {
      throw Exception('Signup failed, user was null.');
    }

    if (displayName != null) {
      await user.updateDisplayName(displayName);
    }

    final now = DateTime.now();
    final userModel = UserModel(
      id: user.uid,
      email: user.email ?? email,
      displayName: displayName,
      createdAt: now,
      updatedAt: now,
    );

    // Store additional profile details in Firestore
    await _firestore.collection('users').doc(user.uid).set(userModel.toMap());

    return userModel;
  }

  /// Login with email + password via Firebase.
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final credentials = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credentials.user;
    if (user == null) {
      throw Exception('Login failed, user was null.');
    }

    final docInfo = await _firestore.collection('users').doc(user.uid).get();
    if (docInfo.exists && docInfo.data() != null) {
      return UserModel.fromMap(docInfo.data()!);
    } else {
      return UserModel(
        id: user.uid,
        email: user.email ?? email,
        displayName: user.displayName,
        createdAt: user.metadata.creationTime ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  /// Log out current user from Firebase.
  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  /// Update user profile fields on Firebase Auth & Firestore.
  Future<void> updateProfile({
    required String userId,
    String? displayName,
    String? avatarUrl,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user != null && user.uid == userId) {
      if (displayName != null) await user.updateDisplayName(displayName);
      if (avatarUrl != null) await user.updatePhotoURL(avatarUrl);
    }

    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (displayName != null) updates['display_name'] = displayName;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    await _firestore.collection('users').doc(userId).update(updates);
  }

  /// Send password reset email
  Future<void> resetPassword({required String email}) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  /// Update password in Firebase Auth
  Future<void> updatePassword({required String newPassword}) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    }
  }

  /// Delete account out of Firebase Auth and Firestore
  Future<void> deleteAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      final uid = user.uid;
      try {
        await _firestore.collection('users').doc(uid).delete();
      } catch (_) {}
      await user.delete();
    }
  }
}
