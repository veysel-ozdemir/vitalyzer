import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitalyzer/app/app.dart';
import 'package:vitalyzer/db/local/database_helper.dart';
import 'package:vitalyzer/util/funtions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load shared preferences data
  final prefs = await SharedPreferences.getInstance();
  // Get database status
  final bool? dbStatus = prefs.getBool('isDBInitialized');

  // Initialize the database if not done yet
  if (dbStatus == null || dbStatus == false) {
    await _initDB();
    await prefs.setBool('isDBInitialized', true);
  }

  // Lock the app orientation to portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const VitalyzerApp());
  });
}

Future<void> _initDB() async {
  // Initialize the database helper
  final dbHelper = DatabaseHelper();
  // Initialize database
  // ignore: unused_local_variable
  final db = await dbHelper.database;

  // Parse CSV
  debugPrint('Starting CSV parse...');
  final foodData = await parseCsv('assets/datasets/food_dataset.csv');
  debugPrint('CSV parsed. Number of rows: ${foodData.length}');

  // Insert into database
  debugPrint('Inserting obtained food data...');
  await dbHelper.insertFoodData(foodData);
  debugPrint('Insertion completed');
}
