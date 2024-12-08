import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:vitalyzer/controller/permission_controller.dart';

class ScanController extends GetxController {
  late List<CameraDescription> _cameras;
  late CameraController _cameraController;
  final RxBool _isInitialized = RxBool(false);
  CameraImage? _cameraImage;
  final RxList<Uint8List> _imageList = RxList([]);

  CameraController get cameraController => _cameraController;
  bool get isInitialized => _isInitialized.value;
  List<Uint8List> get imageList => _imageList;

  final PermissionController permissionController = Get.find();

  @override
  void dispose() {
    // called when the controller is removed from the memory
    _cameraController.dispose();
    _isInitialized.value = false;
    _imageList.clear(); // Clear the image list to reset state
    super.dispose();
  }

  @override
  void onClose() {
    // called when the controller is being deleted
    _cameraController.dispose();
    _isInitialized.value = false;
    _imageList.clear(); // Clear the image list to reset state
    super.onClose();
  }

  Future<void> initCamera() async {
    try {
      debugPrint('-- Initializing Camera --');

      // Explicitly check permissions
      bool permissionsGranted =
          await permissionController.checkCameraAndMicPermissions();

      debugPrint('-- Permissions Granted: $permissionsGranted --');

      if (permissionsGranted) {
        _cameras = await availableCameras();

        if (_cameras.isEmpty) {
          throw 'No cameras available';
        }

        _cameraController = CameraController(
          _cameras[0],
          ResolutionPreset.high,
          imageFormatGroup: ImageFormatGroup.bgra8888,
        );

        await _cameraController.initialize();
        _isInitialized.value = true;
        _cameraController.startImageStream((image) => _cameraImage = image);
        _isInitialized.refresh();

        debugPrint('-- Camera Initialized Successfully --');
      } else {
        _isInitialized.value = false;
        _isInitialized.refresh();
        debugPrint(
            '-- Camera Initialization Failed: Permissions Not Granted --');
      }
    } catch (e) {
      debugPrint('-- Camera Initialization Error: $e --');
      _isInitialized.value = false;
      _isInitialized.refresh();
    }
  }

  void capture() {
    if (_cameraImage != null) {
      img.Image image = img.Image.fromBytes(
        width: _cameraImage!.width,
        height: _cameraImage!.height,
        bytes: _cameraImage!.planes[0].bytes.buffer,
        format: img.Format.uint8,
        order: img.ChannelOrder.bgra,
      );
      Uint8List list = Uint8List.fromList(img.encodeJpg(image));
      _imageList.add(list);
      _imageList.refresh();
    }
  }

  void clearImageList() {
    _imageList.clear();
    _imageList.refresh();
  }
}
