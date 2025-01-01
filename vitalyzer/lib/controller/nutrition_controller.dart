import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vitalyzer/service/gemini_service.dart';

class NutritionController extends GetxController {
  final _geminiService = GeminiService();
  var isAnalyzing = false.obs;
  var analysisResult = ''.obs;

  // Observable values for the nutrition limits
  var waterLimit = 0.0.obs;
  var carbsLimit = 0.0.obs;
  var proteinLimit = 0.0.obs;
  var fatLimit = 0.0.obs;

  var bmiAdvice = ''.obs;

  // Observable values for macro distribution
  var carbsCalories = 0.0.obs;
  var proteinCalories = 0.0.obs;
  var fatCalories = 0.0.obs;

  Future<void> calculateNutritionLimits({
    required int height,
    required double weight,
    required int age,
    required String gender,
  }) async {
    isAnalyzing(true);

    try {
      final result = await _geminiService.calculateNutritionLimits(
        height: height,
        weight: weight,
        age: age,
        gender: gender,
      );

      // Parse the response
      final lines = result.split('\n');
      for (final line in lines) {
        if (line.isEmpty) continue;

        final parts = line.split(':');
        if (parts.length != 2) continue;

        final value = double.tryParse(parts[1].trim()) ?? 0;

        switch (parts[0].trim().toLowerCase()) {
          case 'water':
            waterLimit(value);
            debugPrint('water: $waterLimit');
          case 'carbs':
            carbsLimit(value.toDouble());
            debugPrint('carbsLimit: $carbsLimit');
          case 'protein':
            proteinLimit(value.toDouble());
            debugPrint('proteinLimit: $proteinLimit');
          case 'fat':
            fatLimit(value.toDouble());
            debugPrint('fatLimit: $fatLimit');
        }
      }

      analysisResult(result);
      debugPrint('result: ${analysisResult.value}');
    } catch (e) {
      analysisResult('Error: $e');
    } finally {
      isAnalyzing(false);
    }
  }

  Future<void> getBMIAdvice({
    required double bmi,
    required String gender,
    required int age,
  }) async {
    isAnalyzing(true);

    try {
      final advice = await _geminiService.generateBMIAdvice(
        bmi: bmi,
        gender: gender,
        age: age,
      );

      bmiAdvice(advice);
      debugPrint('BMI Advice: ${bmiAdvice.value}');
    } catch (e) {
      bmiAdvice('Error generating BMI advice: $e');
      debugPrint('Error in getBMIAdvice: $e');
    } finally {
      isAnalyzing(false);
    }
  }

  Future<void> getMacroDistribution(double totalCalories) async {
    isAnalyzing(true);

    try {
      final result =
          await _geminiService.calculateMacroDistribution(totalCalories);

      // Parse the response
      final lines = result.split('\n');
      for (final line in lines) {
        if (line.isEmpty) continue;

        final parts = line.split(':');
        if (parts.length != 2) continue;

        final value = double.tryParse(parts[1].trim()) ?? 0;

        switch (parts[0].trim().toLowerCase()) {
          case 'carbs_cal':
            carbsCalories(value);
            debugPrint('carbsCalories: $carbsCalories');
          case 'protein_cal':
            proteinCalories(value);
            debugPrint('proteinCalories: $proteinCalories');
          case 'fat_cal':
            fatCalories(value);
            debugPrint('fatCalories: $fatCalories');
        }
      }

      debugPrint(
          'Total calories distribution: ${carbsCalories.value + proteinCalories.value + fatCalories.value}');
    } catch (e) {
      debugPrint('Error in getMacroDistribution: $e');
    } finally {
      isAnalyzing(false);
    }
  }
}
