import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionController extends GetxController {
  final RxBool _isCameraPermissionGranted = RxBool(false);
  final RxBool _isMicrophonePermissionGranted = RxBool(false);
  final RxBool _isPhotoLibraryPermissionGranted = RxBool(false);

  bool get isCameraPermissionGranted => _isCameraPermissionGranted.value;
  bool get isMicrophonePermissionGranted =>
      _isMicrophonePermissionGranted.value;
  bool get isPhotoLibraryPermissionGranted =>
      _isPhotoLibraryPermissionGranted.value;

  Future<bool> checkPhotoLibraryPermission() async {
    debugPrint('-- Checking photo library permission status --');

    var status = await Permission.photos.request();

    _isPhotoLibraryPermissionGranted.value =
        status.isGranted || status.isLimited;

    debugPrint('-- Photo library permission status: $status --');

    return _isPhotoLibraryPermissionGranted.value;
  }

  Future<bool> checkCameraAndMicPermissions() async {
    debugPrint('-- Checking permissions --');

    // Request camera permission
    var cameraStatus = await Permission.camera.request();

    _isCameraPermissionGranted.value = cameraStatus.isGranted;

    debugPrint('-- Camera permission status: $cameraStatus --');

    // If camera permission is not granted, return false
    if (!_isCameraPermissionGranted.value) {
      return false;
    }

    // Request microphone permission
    var microphoneStatus = await Permission.microphone.request();

    _isMicrophonePermissionGranted.value = microphoneStatus.isGranted;

    debugPrint('-- Microphone permission status: $microphoneStatus --');

    // Return true only if both permissions are granted
    return _isCameraPermissionGranted.value &&
        _isMicrophonePermissionGranted.value;
  }

  Future<void> openSettings() async {
    await openAppSettings();
  }
}
