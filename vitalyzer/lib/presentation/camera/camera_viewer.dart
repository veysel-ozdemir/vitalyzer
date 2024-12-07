import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vitalyzer/controller/scan_controller.dart';

class CameraViewer extends GetView<ScanController> {
  const CameraViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<ScanController>(
      builder: (controller) {
        if (!controller.isInitialized) {
          return Container();
        }
        return SizedBox(
          height: Get.height,
          width: Get.width,
          child: CameraPreview(controller.cameraController),
        );
      },
    );
  }
}
