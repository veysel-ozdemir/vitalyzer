import 'package:get/instance_manager.dart';
import 'package:vitalyzer/controller/scan_controller.dart';

class GlobalBindings extends Bindings {
  @override
  void dependencies() {
    Get.put<ScanController>(ScanController(), permanent: true);
  }
}
