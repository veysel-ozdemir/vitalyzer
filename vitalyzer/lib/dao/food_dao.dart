import 'package:vitalyzer/db/local/database_helper.dart';

class FoodDao {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertFood(Map<String, dynamic> food) async {
    final db = await _dbHelper.database;
    return await db.insert('Food', food);
  }

  Future<List<Map<String, dynamic>>> getAllFood() async {
    final db = await _dbHelper.database;
    return await db.query('Food');
  }

  Future<int> updateFood(Map<String, dynamic> food) async {
    final db = await _dbHelper.database;
    return await db
        .update('Food', food, where: 'Id = ?', whereArgs: [food['Id']]);
  }

  Future<int> deleteFood(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('Food', where: 'Id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>?> getFoodByName(String name) async {
    return await _dbHelper.getFoodByName(name);
  }
}
