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
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create Food Table
    await createFoodTable(db);

    // Create UserProfile table
    await createUserProfileTable(db);

    // Create UserNutrition table
    await createUserNutritionTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Create new tables that were added after version 1
      await createUserProfileTable(db);
      await createUserNutritionTable(db);
    }
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

  Future<void> createUserProfileTable(Database db) async {
    await db.execute('''
      CREATE TABLE UserProfile (
        UserId INTEGER PRIMARY KEY AUTOINCREMENT,
        FirebaseUserUid TEXT NOT NULL,
        FullName TEXT NOT NULL,
        Email TEXT NOT NULL,
        ProfilePhoto BLOB,
        Height INTEGER NOT NULL,
        Weight REAL NOT NULL,
        Age INTEGER NOT NULL,
        Gender TEXT NOT NULL,
        CreatedAt TEXT NOT NULL,
        UpdatedAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> createUserNutritionTable(Database db) async {
    await db.execute('''
      CREATE TABLE UserNutrition (
        NutritionId INTEGER PRIMARY KEY AUTOINCREMENT,
        UserId INTEGER NOT NULL,
        Date TEXT NOT NULL,
        GainedCarbsCalorie REAL NOT NULL,
        GainedProteinCalorie REAL NOT NULL,
        GainedFatCalorie REAL NOT NULL,
        GainedCarbsGram REAL NOT NULL,
        GainedProteinGram REAL NOT NULL,
        GainedFatGram REAL NOT NULL,
        ConsumedWater REAL NOT NULL,
        WaterLimit REAL NOT NULL,
        CarbsGramLimit REAL NOT NULL,
        ProteinGramLimit REAL NOT NULL,
        FatGramLimit REAL NOT NULL,
        CarbsCalorieLimit REAL NOT NULL,
        ProteinCalorieLimit REAL NOT NULL,
        FatCalorieLimit REAL NOT NULL,
        BmiLevel REAL NOT NULL,
        BmiAdvice TEXT,
        FOREIGN KEY (UserId) REFERENCES UserProfile(UserId)
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

  Future<Map<String, dynamic>?> getFoodByName(String name) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'Food',
      where: 'LOWER(Name) = ?',
      whereArgs: [name.toLowerCase()],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  Future<bool> isTableExists(String tableName) async {
    final db = await database;
    final result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName';");
    debugPrint('Checking if table $tableName exists: ${result.isNotEmpty}');
    return result.isNotEmpty;
  }
}
