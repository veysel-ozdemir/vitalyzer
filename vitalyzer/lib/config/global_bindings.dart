import 'package:get/instance_manager.dart';
import 'package:vitalyzer/controller/permission_controller.dart';
import 'package:vitalyzer/controller/scan_controller.dart';

class GlobalBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(PermissionController(), permanent: true);
    Get.put(ScanController(), permanent: true);
  }
}
