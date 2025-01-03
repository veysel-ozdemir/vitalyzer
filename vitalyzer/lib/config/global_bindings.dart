import 'package:get/instance_manager.dart';
import 'package:vitalyzer/controller/nutrition_controller.dart';
import 'package:vitalyzer/controller/permission_controller.dart';
import 'package:vitalyzer/controller/scan_controller.dart';
import 'package:vitalyzer/controller/user_nutrition_controller.dart';
import 'package:vitalyzer/controller/user_profile_controller.dart';

class GlobalBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(PermissionController(), permanent: true);
    Get.put(ScanController(), permanent: true);
    Get.put(NutritionController(), permanent: true);
    Get.put(UserProfileController(), permanent: true);
    Get.put(UserNutritionController(), permanent: true);
  }
}
