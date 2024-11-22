import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vitalyzer/app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock the app orientation to portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const VitalyzerApp());
  });
}
