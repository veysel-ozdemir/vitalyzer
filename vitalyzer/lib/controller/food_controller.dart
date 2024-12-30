import 'package:get/get.dart';
import 'package:vitalyzer/dao/food_dao.dart';

class FoodController extends GetxController {
  final FoodDao _foodDao = FoodDao();
  var foodList = <Map<String, dynamic>>[].obs;
  var filteredFoodList = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchFood();
  }

  void fetchFood() async {
    foodList.value = await _foodDao.getAllFood();
    filteredFoodList.value = foodList;
  }

  void searchFood(String query) {
    if (query.isEmpty) {
      filteredFoodList.value = foodList;
    } else {
      filteredFoodList.value = foodList
          .where((food) => food['Name']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    }
  }

  Future<Map<String, dynamic>?> getFoodByName(String name) async {
    return await _foodDao.getFoodByName(name);
  }

  Future<void> addFood(Map<String, dynamic> food) async {
    await _foodDao.insertFood(food);
    fetchFood();
  }

  Future<void> updateFood(Map<String, dynamic> food) async {
    await _foodDao.updateFood(food);
    fetchFood();
  }

  Future<void> deleteFood(int id) async {
    await _foodDao.deleteFood(id);
    fetchFood();
  }
}
