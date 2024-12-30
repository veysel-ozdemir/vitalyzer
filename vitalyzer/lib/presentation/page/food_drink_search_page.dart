import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vitalyzer/const/color_palette.dart';
import 'package:vitalyzer/controller/food_controller.dart';
import 'package:vitalyzer/presentation/page/selected_foods_drinks_page.dart';

class FoodDrinkSearchPage extends StatefulWidget {
  const FoodDrinkSearchPage({super.key});

  @override
  State<FoodDrinkSearchPage> createState() => _FoodDrinkSearchPageState();
}

class _FoodDrinkSearchPageState extends State<FoodDrinkSearchPage> {
  final FoodController _foodController = Get.put(FoodController());
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedFoods = {};

  @override
  void initState() {
    super.initState();
    _foodController.fetchFood();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.beige,
      appBar: AppBar(
        backgroundColor: ColorPalette.beige,
        foregroundColor: ColorPalette.green,
        title: const Text('Search Foods & Drinks'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 25, right: 25, left: 25),
        child: Column(
          children: [
            Container(
              color: ColorPalette.beige,
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for food...',
                      hintStyle: TextStyle(
                        color: ColorPalette.darkGreen.withOpacity(0.7),
                        fontSize: 16,
                      ),
                      prefixIcon:
                          const Icon(Icons.search, color: ColorPalette.green),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: ColorPalette.green, width: 5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                          color: ColorPalette.green,
                          width: 2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: ColorPalette.lightGreen, width: 2),
                      ),
                    ),
                    onChanged: (value) {
                      _foodController.searchFood(value);
                    },
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: ColorPalette.green, thickness: 2),
                  const SizedBox(height: 7.5),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                return ListView.builder(
                  itemCount: _foodController.filteredFoodList.length,
                  itemBuilder: (context, index) {
                    final food = _foodController.filteredFoodList[index];
                    final isSelected = _selectedFoods.contains(food['Name']);

                    return Padding(
                      padding: const EdgeInsets.only(top: 2.5, bottom: 2.5),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected
                                ? ColorPalette.lightGreen
                                : ColorPalette.beige,
                            width: 2,
                          ),
                        ),
                        title: Text(
                          food['Name'],
                          style: const TextStyle(
                            color: ColorPalette.darkGreen,
                            fontSize: 16,
                          ),
                        ),
                        tileColor: isSelected
                            ? ColorPalette.lightGreen.withOpacity(0.35)
                            : null,
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              _selectedFoods.remove(food['Name']);
                            } else {
                              _selectedFoods.add(food['Name']);
                            }
                          });
                        },
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _selectedFoods.isEmpty
            ? null
            : () async {
                await Get.to(() => SelectedFoodsDrinksPage(
                      selectedFoods: _selectedFoods.toList(),
                    ));
              },
        backgroundColor: _selectedFoods.isEmpty
            ? ColorPalette.green.withOpacity(0.5)
            : ColorPalette.green,
        label: const Text(
          'Next',
          style: TextStyle(color: ColorPalette.beige, fontSize: 16),
        ),
        icon: const Icon(Icons.arrow_forward, color: ColorPalette.beige),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}
