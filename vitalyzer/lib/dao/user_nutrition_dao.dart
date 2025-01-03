import 'package:vitalyzer/db/local/database_helper.dart';
import 'package:vitalyzer/model/user_nutrition.dart';
import 'package:flutter/foundation.dart';

class UserNutritionDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<int> insertUserNutrition(UserNutrition userNutrition) async {
    final db = await _databaseHelper.database;
    return await db.insert('UserNutrition', userNutrition.toMap());
  }

  Future<List<UserNutrition>> getUserNutritionsByUserId(int userId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'UserNutrition',
      where: 'UserId = ?',
      whereArgs: [userId],
    );

    return List.generate(maps.length, (i) => UserNutrition.fromMap(maps[i]));
  }

  Future<UserNutrition?> getUserNutritionByDate(
      int userId, DateTime date) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'UserNutrition',
      where: 'UserId = ? AND Date = ?',
      whereArgs: [userId, date.toIso8601String()],
    );

    if (maps.isEmpty) return null;
    return UserNutrition.fromMap(maps.first);
  }

  Future<int> updateUserNutrition(UserNutrition userNutrition) async {
    final db = await _databaseHelper.database;
    return await db.update(
      'UserNutrition',
      userNutrition.toMap(),
      where: 'NutritionId = ?',
      whereArgs: [userNutrition.nutritionId],
    );
  }

  Future<int> deleteUserNutrition(int nutritionId) async {
    final db = await _databaseHelper.database;
    return await db.delete(
      'UserNutrition',
      where: 'NutritionId = ?',
      whereArgs: [nutritionId],
    );
  }

  Future<UserNutrition?> getLatestNutritionLimits(int userId) async {
    final db = await _databaseHelper.database;
    debugPrint('Fetching latest nutrition limits for user ID: $userId');

    final List<Map<String, dynamic>> maps = await db.query(
      'UserNutrition',
      where: 'UserId = ?',
      whereArgs: [userId],
      orderBy: 'Date DESC', // Get the most recent record
      limit: 1,
    );

    debugPrint('Query result for latest limits: $maps');
    if (maps.isEmpty) {
      debugPrint('No nutrition limits found for user ID: $userId');
      return null;
    }

    return UserNutrition.fromMap(maps.first);
  }
}
