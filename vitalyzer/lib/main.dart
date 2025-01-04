import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitalyzer/app/app.dart';
import 'package:vitalyzer/db/local/database_helper.dart';
import 'package:vitalyzer/presentation/page/home_page.dart';
import 'package:vitalyzer/presentation/page/landing_page.dart';
import 'package:vitalyzer/util/funtions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:vitalyzer/service/nutrition_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Load the .env file
  await dotenv.load(fileName: ".env");

  // Load shared preferences data
  final prefs = await SharedPreferences.getInstance();
  await initSharedPrefData(prefs);
  debugPrint('\nShared Prefs after init:');
  printKeyValueOfSharedPrefs(prefs);
  // Get database status
  final bool? dbStatus = prefs.getBool('isDBInitialized');

  // Initialize the database if not done yet
  if (dbStatus == null || dbStatus == false) {
    await _initDB();
    await prefs.setBool('isDBInitialized', true);
  }

  // Check for active session and determine starting page
  final Widget startingPage;
  final bool? hasActiveSession = prefs.getBool('hasActiveSession');
  // If first use or no active session
  if (hasActiveSession == null || hasActiveSession == false) {
    startingPage = const LandingPage();
  } else {
    startingPage = const HomePage();
  }

  // Lock the app orientation to portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(VitalyzerApp(startingPage: startingPage));
  });

  // Handle app lifecycle for nutrition data storage
  WidgetsBinding.instance.addObserver(AppLifecycleObserver());
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

class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // Store nutrition data when app is closed or terminated
      NutritionStorageService().storeCurrentDayNutrition(
        DateFormat('yyyy-MM-dd').format(DateTime.now()),
      );
    }
  }
}
