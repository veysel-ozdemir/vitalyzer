import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Private constructor for Singleton
  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'vitalyzer_app_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create Food Table
    await createFoodTable(db);

    // todo: create UserProfile table, including profile photo

    // todo: create UserNutrition table, including date and time
  }

  Future<void> createFoodTable(Database db) async {
    await db.execute('''
      CREATE TABLE Food (
        Id INTEGER PRIMARY KEY AUTOINCREMENT,
        Name TEXT NOT NULL UNIQUE,
        Caloric_Value INTEGER NOT NULL,
        Fat REAL NOT NULL,
        Saturated_Fats REAL NOT NULL,
        Monounsaturated_Fats REAL NOT NULL,
        Polyunsaturated_Fats REAL NOT NULL,
        Carbohydrates REAL NOT NULL,
        Sugars REAL NOT NULL,
        Protein REAL NOT NULL,
        Dietary_Fiber REAL NOT NULL,
        Cholesterol REAL NOT NULL,
        Sodium REAL NOT NULL,
        Water REAL NOT NULL,
        Vitamin_A REAL NOT NULL,
        Vitamin_B1 REAL NOT NULL,
        Vitamin_B11 REAL NOT NULL,
        Vitamin_B12 REAL NOT NULL,
        Vitamin_B2 REAL NOT NULL,
        Vitamin_B3 REAL NOT NULL,
        Vitamin_B5 REAL NOT NULL,
        Vitamin_B6 REAL NOT NULL,
        Vitamin_C REAL NOT NULL,
        Vitamin_D REAL NOT NULL,
        Vitamin_E REAL NOT NULL,
        Vitamin_K REAL NOT NULL,
        Calcium REAL NOT NULL,
        Copper REAL NOT NULL,
        Iron REAL NOT NULL,
        Magnesium REAL NOT NULL,
        Manganese REAL NOT NULL,
        Phosphorus REAL NOT NULL,
        Potassium REAL NOT NULL,
        Selenium REAL NOT NULL,
        Zinc REAL NOT NULL,
        Nutrition_Density REAL NOT NULL
      )
    ''');
  }

  Future<void> insertFoodData(List<Map<String, dynamic>> foodData) async {
    final db = await DatabaseHelper().database;

    for (var food in foodData) {
      try {
        await db.insert(
          'Food',
          food,
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      } catch (e) {
        debugPrint('Error inserting food: $e');
      }
    }
  }
}
