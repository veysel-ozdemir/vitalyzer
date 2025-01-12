import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitalyzer/controller/user_nutrition_controller.dart';
import 'package:vitalyzer/model/user_nutrition.dart';

class NutritionStorageService {
  static final NutritionStorageService _instance =
      NutritionStorageService._internal();
  factory NutritionStorageService() => _instance;
  NutritionStorageService._internal();

  final UserNutritionController _nutritionController = Get.find();

  Future<void> storeCurrentDayNutrition(String today) async {
    final prefs = await SharedPreferences.getInstance();
    final int? userProfileId = prefs.getInt('userProfileId');

    if (userProfileId == null) {
      debugPrint(
          'Could not store current day nutrition because user profile ID is null!');
      return;
    }
    // Check if nutrition data for today already exists
    final existingNutrition = await _nutritionController.getUserNutritionByDate(
      userProfileId,
      DateTime.parse(today),
    );

    // If nutrition data already exists, update it. Otherwise, create new entry
    if (existingNutrition != null) {
      await _nutritionController.updateUserNutrition(UserNutrition(
        nutritionId: existingNutrition.nutritionId,
        userId: userProfileId,
        date: DateTime.parse(today),
        gainedCarbsCalorie: prefs.getDouble('gainedCarbsCalorie') ?? 0.0,
        gainedProteinCalorie: prefs.getDouble('gainedProteinCalorie') ?? 0.0,
        gainedFatCalorie: prefs.getDouble('gainedFatCalorie') ?? 0.0,
        gainedCarbsGram: prefs.getDouble('gainedCarbsGram') ?? 0.0,
        gainedProteinGram: prefs.getDouble('gainedProteinGram') ?? 0.0,
        gainedFatGram: prefs.getDouble('gainedFatGram') ?? 0.0,
        consumedWater: (prefs.getInt('drankWaterBottle')! *
            prefs.getDouble('waterBottleCapacity')!),
        waterLimit: prefs.getDouble('dailyWaterLimit') ?? 0.0,
        carbsGramLimit: prefs.getDouble('carbsGramLimit') ?? 0.0,
        proteinGramLimit: prefs.getDouble('proteinGramLimit') ?? 0.0,
        fatGramLimit: prefs.getDouble('fatGramLimit') ?? 0.0,
        carbsCalorieLimit: prefs.getDouble('carbsCalorieLimit') ?? 0.0,
        proteinCalorieLimit: prefs.getDouble('proteinCalorieLimit') ?? 0.0,
        fatCalorieLimit: prefs.getDouble('fatCalorieLimit') ?? 0.0,
        bmiLevel: prefs.getDouble('bodyMassIndexLevel') ?? 0.0,
        bmiAdvice: prefs.getString('bmiAdvice'),
      ));
    } else {
      await _nutritionController.createUserNutrition(UserNutrition(
        userId: userProfileId,
        date: DateTime.parse(today),
        gainedCarbsCalorie: prefs.getDouble('gainedCarbsCalorie') ?? 0.0,
        gainedProteinCalorie: prefs.getDouble('gainedProteinCalorie') ?? 0.0,
        gainedFatCalorie: prefs.getDouble('gainedFatCalorie') ?? 0.0,
        gainedCarbsGram: prefs.getDouble('gainedCarbsGram') ?? 0.0,
        gainedProteinGram: prefs.getDouble('gainedProteinGram') ?? 0.0,
        gainedFatGram: prefs.getDouble('gainedFatGram') ?? 0.0,
        consumedWater: (prefs.getInt('drankWaterBottle')! *
            prefs.getDouble('waterBottleCapacity')!),
        waterLimit: prefs.getDouble('dailyWaterLimit') ?? 0.0,
        carbsGramLimit: prefs.getDouble('carbsGramLimit') ?? 0.0,
        proteinGramLimit: prefs.getDouble('proteinGramLimit') ?? 0.0,
        fatGramLimit: prefs.getDouble('fatGramLimit') ?? 0.0,
        carbsCalorieLimit: prefs.getDouble('carbsCalorieLimit') ?? 0.0,
        proteinCalorieLimit: prefs.getDouble('proteinCalorieLimit') ?? 0.0,
        fatCalorieLimit: prefs.getDouble('fatCalorieLimit') ?? 0.0,
        bmiLevel: prefs.getDouble('bodyMassIndexLevel') ?? 0.0,
        bmiAdvice: prefs.getString('bmiAdvice'),
      ));
    }

    // Reset daily values after storing
    await _resetDailyValues(prefs);
  }

  Future<void> _resetDailyValues(SharedPreferences prefs) async {
    await prefs.setDouble('gainedCarbsCalorie', 0.0);
    await prefs.setDouble('gainedProteinCalorie', 0.0);
    await prefs.setDouble('gainedFatCalorie', 0.0);
    await prefs.setDouble('gainedCarbsGram', 0.0);
    await prefs.setDouble('gainedProteinGram', 0.0);
    await prefs.setDouble('gainedFatGram', 0.0);
    await prefs.setInt('drankWaterBottle', 0);
    await prefs.remove('waterBottleItemStates');
  }
}
