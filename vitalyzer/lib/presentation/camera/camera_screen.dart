import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vitalyzer/const/color_palette.dart';
import 'package:vitalyzer/controller/permission_controller.dart';
import 'package:vitalyzer/controller/scan_controller.dart';
import 'package:vitalyzer/presentation/camera/camera_viewer.dart';
import 'package:vitalyzer/presentation/camera/capture_button.dart';
import 'package:vitalyzer/util/scan_option.dart';

class CameraScreen extends StatefulWidget {
  final ScanOption scanOption;

  const CameraScreen({super.key, required this.scanOption});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ScanController scanController = Get.find();
  final PermissionController permissionController = Get.find();

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    bool permissionsGranted =
        await permissionController.checkCameraAndMicPermissions();

    if (permissionsGranted) {
      // Trigger camera initialization if permissions are granted
      scanController.initCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (scanController.isLoading.value) {
          // Show loading indicator while initializing
          return const Scaffold(
            backgroundColor: ColorPalette.beige,
            body: Center(
              child: CircularProgressIndicator(color: ColorPalette.lightGreen),
            ),
          );
        }
        return (scanController.isInitialized == true)
            ? PopScope(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const CameraViewer(),
                    CaptureButton(scanOption: widget.scanOption),
                  ],
                ),
              )
            :
            // Permissions not granted, dialog would have been shown
            Scaffold(
                backgroundColor: ColorPalette.beige,
                appBar: AppBar(
                  backgroundColor: ColorPalette.beige,
                  foregroundColor: ColorPalette.green,
                ),
                body: Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Camera and Microphone permissions are required.',
                        style: TextStyle(color: ColorPalette.green),
                      ),
                      const SizedBox(height: 30),
                      TextButton(
                        onPressed: () async =>
                            await permissionController.openSettings(),
                        child: const Text(
                          'Go to settings',
                          style: TextStyle(
                            color: ColorPalette.green,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
      },
    );
  }
}
