import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vitalyzer/controller/permission_controller.dart';
import 'package:vitalyzer/service/gemini_service.dart';

class ScanController extends GetxController {
  late List<CameraDescription> _cameras;
  late CameraController _cameraController;
  final RxBool _isInitialized = RxBool(false);

  CameraController get cameraController => _cameraController;
  bool get isInitialized => _isInitialized.value;

  final PermissionController permissionController = Get.find();
  RxBool isLoading = true.obs;

  final _geminiService = GeminiService();
  var isAnalyzing = false.obs;
  var analysisResult = ''.obs;

  @override
  void dispose() {
    // called when the controller is removed from the memory
    _cameraController.dispose();
    _isInitialized.value = false;
    super.dispose();
  }

  @override
  void onClose() {
    // called when the controller is being deleted
    _cameraController.dispose();
    _isInitialized.value = false;
    super.onClose();
  }

  Future<void> initCamera() async {
    try {
      debugPrint('-- Initializing Camera --');

      isLoading.value = true;

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
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> analyzeImage(XFile image) async {
    try {
      isAnalyzing.value = true;

      // Read image bytes
      final imageBytes = await image.readAsBytes();

      // Analyze with Gemini
      final result = await _geminiService.analyzeImageAndText(
        imageBytes,
        'Analyze this food image and provide nutritional information and ingredients if visible.',
      );

      analysisResult.value = result;
    } catch (e) {
      analysisResult.value = 'Error analyzing image: $e';
    } finally {
      isAnalyzing.value = false;
    }
  }

  Future<XFile?> takePicture() async {
    if (!_cameraController.value.isInitialized) {
      return null;
    }
    try {
      final XFile image = await _cameraController.takePicture();
      return image;
    } catch (e) {
      debugPrint('Error taking picture: $e');
      return null;
    }
  }
}
