import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vitalyzer/const/color_palette.dart';
import 'package:vitalyzer/controller/scan_controller.dart';
import 'package:vitalyzer/presentation/camera/scan_result_page.dart';

class ConfirmImagePage extends StatelessWidget {
  final XFile image;
  final ScanController controller = Get.find();

  ConfirmImagePage({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.beige,
      appBar: AppBar(
        backgroundColor: ColorPalette.beige,
        foregroundColor: ColorPalette.green,
        title: const Text('Confirm Image'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 25),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: ColorPalette.green, width: 3)),
              child: Image.file(
                File(image.path),
                fit: BoxFit.contain,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 50.0, bottom: 50.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size.fromWidth(Get.width * 0.3),
                      backgroundColor: ColorPalette.beige,
                      shape: const RoundedRectangleBorder(
                        side: BorderSide(color: ColorPalette.green, width: 2),
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                    ),
                    child: const Text('Retake',
                        style: TextStyle(
                          color: ColorPalette.green,
                          fontSize: 16,
                        )),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await controller.analyzeImage(image);
                    Get.to(() => const ScanResultPage());
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size.fromWidth(Get.width * 0.3),
                    backgroundColor: ColorPalette.green,
                    shape: const RoundedRectangleBorder(
                      side: BorderSide(color: ColorPalette.green, width: 2),
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                  ),
                  child: const Text('Analyze',
                      style: TextStyle(
                        color: ColorPalette.beige,
                        fontSize: 16,
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
