class UserNutrition {
  final int? nutritionId;
  final int userId;
  final DateTime date;
  final double gainedCarbsCalorie;
  final double gainedProteinCalorie;
  final double gainedFatCalorie;
  final double gainedCarbsGram;
  final double gainedProteinGram;
  final double gainedFatGram;
  final double consumedWater;
  final double waterLimit;
  final double carbsGramLimit;
  final double proteinGramLimit;
  final double fatGramLimit;
  final double carbsCalorieLimit;
  final double proteinCalorieLimit;
  final double fatCalorieLimit;
  final double bmiLevel;
  final String? bmiAdvice;

  UserNutrition({
    this.nutritionId,
    required this.userId,
    required this.date,
    required this.gainedCarbsCalorie,
    required this.gainedProteinCalorie,
    required this.gainedFatCalorie,
    required this.gainedCarbsGram,
    required this.gainedProteinGram,
    required this.gainedFatGram,
    required this.consumedWater,
    required this.waterLimit,
    required this.carbsGramLimit,
    required this.proteinGramLimit,
    required this.fatGramLimit,
    required this.carbsCalorieLimit,
    required this.proteinCalorieLimit,
    required this.fatCalorieLimit,
    required this.bmiLevel,
    this.bmiAdvice,
  });

  Map<String, dynamic> toMap() {
    return {
      'NutritionId': nutritionId,
      'UserId': userId,
      'Date': date.toIso8601String(),
      'GainedCarbsCalorie': gainedCarbsCalorie,
      'GainedProteinCalorie': gainedProteinCalorie,
      'GainedFatCalorie': gainedFatCalorie,
      'GainedCarbsGram': gainedCarbsGram,
      'GainedProteinGram': gainedProteinGram,
      'GainedFatGram': gainedFatGram,
      'ConsumedWater': consumedWater,
      'WaterLimit': waterLimit,
      'CarbsGramLimit': carbsGramLimit,
      'ProteinGramLimit': proteinGramLimit,
      'FatGramLimit': fatGramLimit,
      'CarbsCalorieLimit': carbsCalorieLimit,
      'ProteinCalorieLimit': proteinCalorieLimit,
      'FatCalorieLimit': fatCalorieLimit,
      'BmiLevel': bmiLevel,
      'BmiAdvice': bmiAdvice,
    };
  }

  factory UserNutrition.fromMap(Map<String, dynamic> map) {
    return UserNutrition(
      nutritionId: map['NutritionId'],
      userId: map['UserId'],
      date: DateTime.parse(map['Date']),
      gainedCarbsCalorie: map['GainedCarbsCalorie'],
      gainedProteinCalorie: map['GainedProteinCalorie'],
      gainedFatCalorie: map['GainedFatCalorie'],
      gainedCarbsGram: map['GainedCarbsGram'],
      gainedProteinGram: map['GainedProteinGram'],
      gainedFatGram: map['GainedFatGram'],
      consumedWater: map['ConsumedWater'],
      waterLimit: map['WaterLimit'],
      carbsGramLimit: map['CarbsGramLimit'],
      proteinGramLimit: map['ProteinGramLimit'],
      fatGramLimit: map['FatGramLimit'],
      carbsCalorieLimit: map['CarbsCalorieLimit'],
      proteinCalorieLimit: map['ProteinCalorieLimit'],
      fatCalorieLimit: map['FatCalorieLimit'],
      bmiLevel: map['BmiLevel'],
      bmiAdvice: map['BmiAdvice'],
    );
  }
}
