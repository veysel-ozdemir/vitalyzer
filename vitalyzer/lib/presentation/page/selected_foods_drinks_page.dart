import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitalyzer/const/color_palette.dart';
import 'package:vitalyzer/controller/food_controller.dart';
import 'package:vitalyzer/presentation/page/home_page.dart';

class SelectedFoodsDrinksPage extends StatefulWidget {
  final List<String> selectedFoods;

  const SelectedFoodsDrinksPage({
    super.key,
    required this.selectedFoods,
  });

  @override
  State<SelectedFoodsDrinksPage> createState() =>
      _SelectedFoodsDrinksPageState();
}

class _SelectedFoodsDrinksPageState extends State<SelectedFoodsDrinksPage> {
  final Map<String, int> _foodAmounts = {};
  final FoodController _foodController = FoodController();
  late SharedPreferences prefs;
  int? carbsCaloriePerGram;
  int? proteinCaloriePerGram;
  int? fatCaloriePerGram;
  double? gainedCarbsGram;
  double? gainedProteinGram;
  double? gainedFatGram;
  double? gainedCarbsCalorie;
  double? gainedProteinCalorie;
  double? gainedFatCalorie;

  @override
  void initState() {
    super.initState();
    for (var food in widget.selectedFoods) {
      _foodAmounts[food] = 100;
    }
    _loadSharedPrefs();
  }

  Future<void> _loadSharedPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      carbsCaloriePerGram = prefs.getInt('carbsCaloriePerGram');
      proteinCaloriePerGram = prefs.getInt('proteinCaloriePerGram');
      fatCaloriePerGram = prefs.getInt('fatCaloriePerGram');
      gainedCarbsCalorie = prefs.getDouble('gainedCarbsCalorie');
      gainedProteinCalorie = prefs.getDouble('gainedProteinCalorie');
      gainedFatCalorie = prefs.getDouble('gainedFatCalorie');
      gainedCarbsGram = prefs.getDouble('gainedCarbsGram');
      gainedProteinGram = prefs.getDouble('gainedProteinGram');
      gainedFatGram = prefs.getDouble('gainedFatGram');
    });
  }

  Future<void> _saveDataToSharedPrefs() async {
    await prefs.setDouble('gainedCarbsCalorie', gainedCarbsCalorie!);
    await prefs.setDouble('gainedProteinCalorie', gainedProteinCalorie!);
    await prefs.setDouble('gainedFatCalorie', gainedFatCalorie!);
    await prefs.setDouble('gainedCarbsGram', gainedCarbsGram!);
    await prefs.setDouble('gainedProteinGram', gainedProteinGram!);
    await prefs.setDouble('gainedFatGram', gainedFatGram!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.beige,
      appBar: AppBar(
        backgroundColor: ColorPalette.beige,
        foregroundColor: ColorPalette.green,
        title: const Text('Your Selections'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: widget.selectedFoods.length,
                itemBuilder: (context, index) {
                  final foodName = widget.selectedFoods[index];
                  return Card(
                    color: ColorPalette.beige,
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              foodName,
                              style: const TextStyle(
                                fontSize: 16,
                                color: ColorPalette.darkGreen,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                color: ColorPalette.green,
                                onPressed: () {
                                  setState(() {
                                    if (_foodAmounts[foodName]! > 100) {
                                      _foodAmounts[foodName] =
                                          _foodAmounts[foodName]! - 100;
                                    }
                                  });
                                },
                              ),
                              Text(
                                '${_foodAmounts[foodName]}g',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: ColorPalette.darkGreen,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                color: ColorPalette.green,
                                onPressed: () {
                                  setState(() {
                                    _foodAmounts[foodName] =
                                        _foodAmounts[foodName]! + 100;
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                for (var food in _foodAmounts.keys) {
                  // get amount per 100
                  int amount = (_foodAmounts[food]! / 100).floor();
                  // get the food instance
                  Map? foodMap = await _foodController.getFoodByName(food);
                  if (foodMap != null) {
                    // get macronutrients per 100g
                    double carbs = foodMap['Carbohydrates'];
                    double protein = foodMap['Protein'];
                    double fat = foodMap['Fat'];

                    // add to gains
                    gainedCarbsGram = gainedCarbsGram! + (carbs * amount);
                    gainedProteinGram = gainedProteinGram! + (protein * amount);
                    gainedFatGram = gainedFatGram! + (fat * amount);

                    // calculate kcal/g of each and add to gains
                    gainedCarbsCalorie = gainedCarbsCalorie! +
                        (carbs * carbsCaloriePerGram! * amount);
                    gainedProteinCalorie = gainedProteinCalorie! +
                        (protein * proteinCaloriePerGram! * amount);
                    gainedFatCalorie =
                        gainedFatCalorie! + (fat * fatCaloriePerGram! * amount);
                  } else {
                    debugPrint('No food found!: $food');
                  }
                }
                // save data to shared prefs
                await _saveDataToSharedPrefs();
                // navigate back to home page
                await Get.offAll(() => const HomePage());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorPalette.lightGreen,
                minimumSize: Size(Get.width * 0.5, 50),
              ),
              child: const Text(
                'Save',
                style: TextStyle(
                  color: ColorPalette.beige,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
