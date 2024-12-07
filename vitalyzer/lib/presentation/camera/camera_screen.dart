import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vitalyzer/controller/scan_controller.dart';
import 'package:vitalyzer/presentation/camera/camera_viewer.dart';
import 'package:vitalyzer/presentation/camera/capture_button.dart';
import 'package:vitalyzer/presentation/camera/top_image_viewer.dart';

class CameraScreen extends StatelessWidget {
  final ScanController controller = Get.find<ScanController>();

  CameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) => controller.clearImageList(),
      child: const Stack(
        alignment: Alignment.center,
        children: [
          CameraViewer(),
          CaptureButton(),
          TopImageViewer(),
        ],
      ),
    );
  }
}
