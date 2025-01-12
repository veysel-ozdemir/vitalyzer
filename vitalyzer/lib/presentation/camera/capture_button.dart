import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vitalyzer/controller/scan_controller.dart';
import 'package:vitalyzer/presentation/camera/confirm_image_page.dart';
import 'package:vitalyzer/util/scan_option.dart';

class CaptureButton extends GetView<ScanController> {
  final ScanOption scanOption;

  const CaptureButton({super.key, required this.scanOption});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 30,
      child: GestureDetector(
        onTap: () async {
          final image = await controller.takePicture();
          if (image != null) {
            Get.to(
              () => ConfirmImagePage(image: image, scanOption: scanOption),
            );
          }
        },
        child: Container(
          height: Get.height * 0.2,
          width: Get.width * 0.2,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.transparent,
            border: Border.all(
              color: Colors.white,
              width: 5,
            ),
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.camera,
                size: 60,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
