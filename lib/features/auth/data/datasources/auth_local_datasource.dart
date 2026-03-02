import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database_helper.dart';
import '../models/user_model.dart';

/// Local datasource for auth — uses SQLite + SharedPreferences.
class AuthLocalDatasource {
  final DatabaseHelper _dbHelper;
  final SharedPreferences _prefs;

  static const _currentUserKey = 'current_user_id';

  AuthLocalDatasource(this._dbHelper, this._prefs);

  /// Get the currently logged-in user from local storage.
  Future<UserModel?> getCurrentUser() async {
    final userId = _prefs.getString(_currentUserKey);
    if (userId == null) return null;

    final db = await _dbHelper.database;
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (results.isEmpty) return null;
    return UserModel.fromMap(results.first);
  }

  /// Register a new user locally (hash password in production).
  Future<UserModel> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final db = await _dbHelper.database;

    // Check if email already exists
    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (existing.isNotEmpty) {
      throw Exception('An account with this email already exists.');
    }

    final now = DateTime.now();
    final user = UserModel(
      id: const Uuid().v4(),
      email: email,
      displayName: displayName,
      createdAt: now,
      updatedAt: now,
    );

    await db.insert('users', user.toMap());
    // Store password hash (simplified — use bcrypt in production)
    await _prefs.setString(
      'pwd_${user.id}',
      base64Encode(utf8.encode(password)),
    );
    await _prefs.setString(_currentUserKey, user.id);

    return user;
  }

  /// Login with email + password.
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (results.isEmpty) {
      throw Exception('No account found with this email.');
    }

    final user = UserModel.fromMap(results.first);
    final storedPassword = _prefs.getString('pwd_${user.id}');
    final encodedPassword = base64Encode(utf8.encode(password));

    if (storedPassword != encodedPassword) {
      throw Exception('Incorrect password.');
    }

    await _prefs.setString(_currentUserKey, user.id);
    return user;
  }

  /// Log out current user.
  Future<void> logout() async {
    await _prefs.remove(_currentUserKey);
  }

  /// Update user profile fields.
  Future<void> updateProfile({
    required String userId,
    String? displayName,
    String? avatarUrl,
  }) async {
    final db = await _dbHelper.database;
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (displayName != null) updates['display_name'] = displayName;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    await db.update('users', updates, where: 'id = ?', whereArgs: [userId]);
  }
}
