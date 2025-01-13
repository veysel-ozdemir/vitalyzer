import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  late final GenerativeModel _model;

  factory GeminiService() {
    return _instance;
  }

  GeminiService._internal() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
    );
  }

  Future<String> analyzeImageAndText(Uint8List imageBytes) async {
    try {
      const prompt =
          'Analyze this food image and provide nutritional information and ingredients if visible.';
      final content = [
        Content.text(prompt),
        Content.data('image/jpeg', imageBytes),
      ];

      final response = await _model.generateContent(content);
      return response.text ?? 'No response generated';
    } catch (e) {
      return 'Error analyzing image: $e';
    }
  }

  Future<String> scanWaterBottle(Uint8List imageBytes) async {
    try {
      const prompt = '''
        Analyze this water bottle image and, if visible, provide the amount of water drunk in L.
        If the capacity is not clearly visible, provide the estimated amount in L, which should be rounded to nearest 0.5L.
        If the water bottle is clearly empty, assume that the whole bottle is consumed.
        In addition to the text of description, clearly state the estimated amount in the following format:
        - Estimated water drunk: [estimated amount in L, which should be rounded to nearest 0.5L]
      ''';
      final content = [
        Content.text(prompt),
        Content.data('image/jpeg', imageBytes),
      ];

      final response = await _model.generateContent(content);
      return response.text ?? 'No response generated';
    } catch (e) {
      return 'Error analyzing image: $e';
    }
  }

  Future<String> calculateNutritionLimits({
    required int height,
    required double weight,
    required int age,
    required String gender,
  }) async {
    final prompt = '''
    Act as a nutritionist and calculate the following daily limits based on these parameters:
    Height: $height cm
    Weight: $weight kg
    Age: $age years
    Gender: $gender

    Please calculate and provide ONLY these values in the following format without any additional text (only precise numeric values without their units):
    water: [appropriate daily water intake in L between 0.5 and 4.5 inclusive range, rounded to nearest 0.5L]
    carbs: [appropriate daily carbohydrates in grams]
    protein: [appropriate daily protein in grams]
    fat: [appropriate daily fat in grams]
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'No response generated';
    } catch (e) {
      return 'Error calculating nutrition limits: $e';
    }
  }

  Future<String> generateBMIAdvice({
    required double bmi,
    required String gender,
    required int age,
  }) async {
    String bmiCategory;
    if (bmi < 18.5) {
      bmiCategory = 'underweight';
    } else if (bmi < 25) {
      bmiCategory = 'healthy weight';
    } else if (bmi < 30) {
      bmiCategory = 'overweight';
    } else if (bmi < 40) {
      bmiCategory = 'obesity';
    } else {
      bmiCategory = 'severe obesity';
    }

    final prompt = '''
    Act as a caring and professional medical advisor. I have a patient with the following characteristics:
    - BMI: $bmi (falls into $bmiCategory category)
    - Gender: $gender
    - Age: $age years

    Please provide a personalized medical advice that includes:
    1. A brief explanation of their current BMI status and what it means for their health
    2. Potential health risks associated with their current BMI category
    3. Specific, actionable recommendations to achieve/maintain a healthy weight
    4. Motivational message to encourage them on their health journey

    Keep the tone professional yet empathetic and encouraging. Make the advice practical and achievable.
    Do not include greeting or thanking sentences. Just start with the personalized medical advice text.
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'No response generated';
    } catch (e) {
      return 'Error generating BMI advice: $e';
    }
  }

  Future<String> calculateMacroDistribution(double totalCalories) async {
    final prompt = '''
    Act as a nutritionist. Calculate the appropriate daily macronutrient distribution in calories for a total daily calorie intake of $totalCalories kcal.

    Follow these guidelines:
    - Carbohydrates should be 45-55% of total calories
    - Protein should be 25-35% of total calories
    - Fat should be 20-30% of total calories
    
    Please provide ONLY these values in the following format without any additional text (only precise numeric values without their units):
    carbs_cal: [appropriate daily carbohydrate calories]
    protein_cal: [appropriate daily protein calories]
    fat_cal: [appropriate daily fat calories]

    Ensure that the sum of all macronutrient calories equals exactly $totalCalories.
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? 'No response generated';
    } catch (e) {
      return 'Error calculating macro distribution: $e';
    }
  }
}
