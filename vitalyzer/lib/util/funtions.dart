import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

// Initialize the essentials
Future<void> initSharedPrefData(SharedPreferences prefs) async {
  // Set the standard kcal/g of macronutrients (4-4-9)
  await prefs.setInt('carbsCaloriePerGram', 4);
  await prefs.setInt('proteinCaloriePerGram', 4);
  await prefs.setInt('fatCaloriePerGram', 9);
  // Set determined water bottle capacity
  await prefs.setDouble('waterBottleCapacity', 0.5);
}

// Print each key-value pairs of Shared Prefs
void printKeyValueOfSharedPrefs(SharedPreferences prefs) {
  for (var k in prefs.getKeys()) {
    debugPrint('$k: ${prefs.get(k)}');
  }
}

// calculate the body mass index (BMI) in kg & cm
double calculateBodyMassIndex({
  required double kgWeight,
  required int cmHeight,
}) {
  double mHeight = cmHeight / 100;
  double result = (kgWeight / (mHeight * mHeight));
  String precisioned = result.toStringAsPrecision(4);
  return double.parse(precisioned);
}

// migrate the dataset into the local database table
Future<List<Map<String, dynamic>>> parseCsv(String path) async {
  try {
    debugPrint('Loading CSV from: $path');
    final rawData = await rootBundle.loadString(path);
    debugPrint('Raw data length: ${rawData.length}');

    // Configure CSV converter with proper settings
    const converter = CsvToListConverter(
      shouldParseNumbers: true,
      fieldDelimiter: ',',
      eol: '\n', // Explicitly set end of line character
    );

    final List<List<dynamic>> rows = converter.convert(rawData);
    debugPrint('Number of rows after conversion: ${rows.length}');

    // Filter out empty rows
    final filteredRows = rows
        .where((row) =>
            row.isNotEmpty &&
            row.any(
                (cell) => cell != null && cell.toString().trim().isNotEmpty))
        .toList();
    debugPrint(
        'Number of rows after filtering empty rows: ${filteredRows.length}');

    if (filteredRows.isEmpty) {
      debugPrint('No valid rows found in CSV!');
      return [];
    }

    // Convert all header values to strings and trim whitespace
    final List<String> headers =
        filteredRows.first.map((header) => header.toString().trim()).toList();
    debugPrint('Headers found: $headers');

    final dataRows = filteredRows.skip(1).toList();
    debugPrint('Number of data rows (excluding headers): ${dataRows.length}');

    // Convert to a list of maps
    return dataRows.map((row) {
      final Map<String, dynamic> rowMap = {};
      for (var i = 0; i < headers.length && i < row.length; i++) {
        // Convert cell to appropriate type and trim whitespace if string
        var value = row[i];
        if (value is String) {
          value = value.trim();
        }
        rowMap[headers[i]] = value;
      }
      return rowMap;
    }).toList();
  } catch (e, stackTrace) {
    debugPrint('Error parsing CSV: $e');
    debugPrint('Stack trace: $stackTrace');
    rethrow;
  }
}

// convert image to bytes
Future<Uint8List> convertXFileToUint8List(XFile image) async =>
    await image.readAsBytes();

// convert bytes to image
Future<XFile> convertUint8ListToXFile(
    Uint8List uint8List, String fileName) async {
  // Get the temporary directory manually
  String tempDirPath = Directory.systemTemp.path;

  // Combine the temporary directory path with the file name
  String filePath = path.join(tempDirPath, fileName);

  // Create a temporary file and write the Uint8List to it
  File tempFile = File(filePath);
  await tempFile.writeAsBytes(uint8List);

  // Return the file as an XFile
  return XFile(tempFile.path);
}
