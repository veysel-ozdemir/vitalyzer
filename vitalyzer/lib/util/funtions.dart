import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
