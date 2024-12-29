import 'package:get/get.dart';
import 'package:vitalyzer/dao/food_dao.dart';

class FoodController extends GetxController {
  final FoodDao _foodDao = FoodDao();
  var foodList = <Map<String, dynamic>>[].obs;

  void fetchFood() async {
    foodList.value = await _foodDao.getAllFood();
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
