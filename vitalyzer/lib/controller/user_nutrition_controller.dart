import 'package:get/get.dart';
import 'package:vitalyzer/dao/user_nutrition_dao.dart';
import 'package:vitalyzer/model/user_nutrition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class UserNutritionController extends GetxController {
  final UserNutritionDao _userNutritionDao = UserNutritionDao();
  final RxList<UserNutrition> userNutritions = <UserNutrition>[].obs;

  // Observable values for the limits
  final Rx<double> waterLimit = 0.0.obs;
  final Rx<double> carbsGramLimit = 0.0.obs;
  final Rx<double> proteinGramLimit = 0.0.obs;
  final Rx<double> fatGramLimit = 0.0.obs;
  final Rx<double> carbsCalorieLimit = 0.0.obs;
  final Rx<double> proteinCalorieLimit = 0.0.obs;
  final Rx<double> fatCalorieLimit = 0.0.obs;
  final Rx<double> bmiLevel = 0.0.obs;
  final Rx<String?> bmiAdvice = Rx<String?>(null);

  Future<void> createUserNutrition(UserNutrition userNutrition) async {
    await _userNutritionDao.insertUserNutrition(userNutrition);
    userNutritions.add(userNutrition);
  }

  Future<void> loadUserNutritions(int userId) async {
    final nutritions =
        await _userNutritionDao.getUserNutritionsByUserId(userId);
    userNutritions.value = nutritions;
  }

  Future<UserNutrition?> getUserNutritionByDate(
      int userId, DateTime date) async {
    return await _userNutritionDao.getUserNutritionByDate(userId, date);
  }

  Future<void> updateUserNutrition(UserNutrition userNutrition) async {
    await _userNutritionDao.updateUserNutrition(userNutrition);
    final index = userNutritions
        .indexWhere((n) => n.nutritionId == userNutrition.nutritionId);
    if (index != -1) {
      userNutritions[index] = userNutrition;
    }
  }

  Future<void> deleteUserNutrition(int nutritionId) async {
    await _userNutritionDao.deleteUserNutrition(nutritionId);
    userNutritions.removeWhere((n) => n.nutritionId == nutritionId);
  }

  Future<void> loadLatestNutritionLimits(int userId) async {
    try {
      final latestNutrition =
          await _userNutritionDao.getLatestNutritionLimits(userId);

      if (latestNutrition != null) {
        // Update the observable values
        waterLimit.value = latestNutrition.waterLimit;
        carbsGramLimit.value = latestNutrition.carbsGramLimit;
        proteinGramLimit.value = latestNutrition.proteinGramLimit;
        fatGramLimit.value = latestNutrition.fatGramLimit;
        carbsCalorieLimit.value = latestNutrition.carbsCalorieLimit;
        proteinCalorieLimit.value = latestNutrition.proteinCalorieLimit;
        fatCalorieLimit.value = latestNutrition.fatCalorieLimit;
        bmiLevel.value = latestNutrition.bmiLevel;
        bmiAdvice.value = latestNutrition.bmiAdvice;

        // Also update SharedPreferences for persistence
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('dailyWaterLimit', latestNutrition.waterLimit);
        await prefs.setDouble('carbsGramLimit', latestNutrition.carbsGramLimit);
        await prefs.setDouble(
            'proteinGramLimit', latestNutrition.proteinGramLimit);
        await prefs.setDouble('fatGramLimit', latestNutrition.fatGramLimit);
        await prefs.setDouble(
            'carbsCalorieLimit', latestNutrition.carbsCalorieLimit);
        await prefs.setDouble(
            'proteinCalorieLimit', latestNutrition.proteinCalorieLimit);
        await prefs.setDouble(
            'fatCalorieLimit', latestNutrition.fatCalorieLimit);
        await prefs.setDouble('bodyMassIndexLevel', latestNutrition.bmiLevel);
        if (latestNutrition.bmiAdvice != null) {
          await prefs.setString('bmiAdvice', latestNutrition.bmiAdvice!);
        }

        debugPrint(
            'Successfully loaded latest nutrition limits for user $userId');
      } else {
        debugPrint('No previous nutrition limits found for user $userId');
      }
    } catch (e) {
      debugPrint('Error loading latest nutrition limits: $e');
    }
  }

  // Helper method to get all limits as a map
  Map<String, dynamic> getAllLimits() {
    return {
      'waterLimit': waterLimit.value,
      'carbsGramLimit': carbsGramLimit.value,
      'proteinGramLimit': proteinGramLimit.value,
      'fatGramLimit': fatGramLimit.value,
      'carbsCalorieLimit': carbsCalorieLimit.value,
      'proteinCalorieLimit': proteinCalorieLimit.value,
      'fatCalorieLimit': fatCalorieLimit.value,
      'bmiLevel': bmiLevel.value,
      'bmiAdvice': bmiAdvice.value,
    };
  }

  Future<void> initializeUserNutritionData(int userId) async {
    try {
      final today =
          DateTime.parse(DateFormat('yyyy-MM-dd').format(DateTime.now()));
      debugPrint('Checking nutrition data for date: $today');

      // Check if there's data for today
      final todayNutrition = await getUserNutritionByDate(userId, today);

      if (todayNutrition != null) {
        debugPrint('Found existing nutrition data for today');
        // Update SharedPreferences with today's data
        final prefs = await SharedPreferences.getInstance();
        final waterBottleCapacity = prefs.getDouble('waterBottleCapacity');
        final dailyWaterLimit = prefs.getDouble('dailyWaterLimit');

        // Set gained values
        await prefs.setDouble(
            'gainedCarbsCalorie', todayNutrition.gainedCarbsCalorie);
        await prefs.setDouble(
            'gainedProteinCalorie', todayNutrition.gainedProteinCalorie);
        await prefs.setDouble(
            'gainedFatCalorie', todayNutrition.gainedFatCalorie);
        await prefs.setDouble(
            'gainedCarbsGram', todayNutrition.gainedCarbsGram);
        await prefs.setDouble(
            'gainedProteinGram', todayNutrition.gainedProteinGram);
        await prefs.setDouble('gainedFatGram', todayNutrition.gainedFatGram);

        // Set the drank water bottle
        int drankWaterBottle =
            (todayNutrition.consumedWater / waterBottleCapacity!).toInt();
        await prefs.setInt('drankWaterBottle', drankWaterBottle);

        // Set the water states
        final waterBottleItemCount =
            (dailyWaterLimit! / waterBottleCapacity).toInt();
        await prefs.setStringList(
            'waterBottleItemStates',
            List.generate(waterBottleItemCount, (_) {
              if ((drankWaterBottle--) > 0) {
                return true;
              }
              return false;
            }).map((e) => e.toString()).toList());

        // Set limit values
        await prefs.setDouble('dailyWaterLimit', todayNutrition.waterLimit);
        await prefs.setDouble('carbsGramLimit', todayNutrition.carbsGramLimit);
        await prefs.setDouble(
            'proteinGramLimit', todayNutrition.proteinGramLimit);
        await prefs.setDouble('fatGramLimit', todayNutrition.fatGramLimit);
        await prefs.setDouble(
            'carbsCalorieLimit', todayNutrition.carbsCalorieLimit);
        await prefs.setDouble(
            'proteinCalorieLimit', todayNutrition.proteinCalorieLimit);
        await prefs.setDouble(
            'fatCalorieLimit', todayNutrition.fatCalorieLimit);
        await prefs.setDouble('bodyMassIndexLevel', todayNutrition.bmiLevel);
        if (todayNutrition.bmiAdvice != null) {
          await prefs.setString('bmiAdvice', todayNutrition.bmiAdvice!);
        }

        // Update observable values
        waterLimit.value = todayNutrition.waterLimit;
        carbsGramLimit.value = todayNutrition.carbsGramLimit;
        proteinGramLimit.value = todayNutrition.proteinGramLimit;
        fatGramLimit.value = todayNutrition.fatGramLimit;
        carbsCalorieLimit.value = todayNutrition.carbsCalorieLimit;
        proteinCalorieLimit.value = todayNutrition.proteinCalorieLimit;
        fatCalorieLimit.value = todayNutrition.fatCalorieLimit;
        bmiLevel.value = todayNutrition.bmiLevel;
        bmiAdvice.value = todayNutrition.bmiAdvice;
      } else {
        debugPrint('No nutrition data found for today, loading latest limits');
        // Load limits from the most recent record
        await loadLatestNutritionLimits(userId);

        // Reset gained values in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('gainedCarbsCalorie', 0.0);
        await prefs.setDouble('gainedProteinCalorie', 0.0);
        await prefs.setDouble('gainedFatCalorie', 0.0);
        await prefs.setDouble('gainedCarbsGram', 0.0);
        await prefs.setDouble('gainedProteinGram', 0.0);
        await prefs.setDouble('gainedFatGram', 0.0);
        await prefs.setInt('drankWaterBottle', 0);

        // Create new nutrition record for today with zero gains
        final newNutrition = UserNutrition(
          userId: userId,
          date: today,
          gainedCarbsCalorie: 0.0,
          gainedProteinCalorie: 0.0,
          gainedFatCalorie: 0.0,
          gainedCarbsGram: 0.0,
          gainedProteinGram: 0.0,
          gainedFatGram: 0.0,
          consumedWater: 0.0,
          waterLimit: waterLimit.value,
          carbsGramLimit: carbsGramLimit.value,
          proteinGramLimit: proteinGramLimit.value,
          fatGramLimit: fatGramLimit.value,
          carbsCalorieLimit: carbsCalorieLimit.value,
          proteinCalorieLimit: proteinCalorieLimit.value,
          fatCalorieLimit: fatCalorieLimit.value,
          bmiLevel: bmiLevel.value,
          bmiAdvice: bmiAdvice.value,
        );

        await createUserNutrition(newNutrition);
      }
    } catch (e) {
      debugPrint('Error initializing user nutrition data: $e');
    }
  }
}
