import 'package:vitalyzer/db/local/database_helper.dart';
import 'package:vitalyzer/model/user_profile.dart';
import 'package:flutter/foundation.dart';

class UserProfileDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insertUserProfile(UserProfile userProfile) async {
    final db = await _databaseHelper.database;
    final result = await db.insert('UserProfile', userProfile.toMap());
    debugPrint('Inserted profile with ID: $result');
    return result;
  }

  Future<UserProfile?> getUserProfileByFirebaseUid(String firebaseUid) async {
    final db = await _databaseHelper.database;
    debugPrint('Searching for profile with Firebase UID: $firebaseUid');
    final List<Map<String, dynamic>> maps = await db.query(
      'UserProfile',
      where: 'FirebaseUserUid = ?',
      whereArgs: [firebaseUid],
    );

    debugPrint('Query result: $maps');
    if (maps.isEmpty) {
      debugPrint('No profile found for Firebase UID: $firebaseUid');
      return null;
    }
    return UserProfile.fromMap(maps.first);
  }

  Future<int> updateUserProfile(UserProfile userProfile) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'UserProfile',
      userProfile.toMap(),
      where: 'UserId = ?',
      whereArgs: [userProfile.userId],
    );
  }

  Future<int> deleteUserProfile(int userId) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'UserProfile',
      where: 'UserId = ?',
      whereArgs: [userId],
    );
  }
}
