import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;

class ScanController extends GetxController {
  late List<CameraDescription> _cameras;
  late CameraController _cameraController;
  final RxBool _isInitialized = RxBool(false);
  CameraImage? _cameraImage;
  final RxList<Uint8List> _imageList = RxList([]);

  CameraController get cameraController => _cameraController;
  bool get isInitialized => _isInitialized.value;
  List<Uint8List> get imageList => _imageList;

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
    _cameras = await availableCameras();
    _cameraController = CameraController(
      _cameras[0],
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.bgra8888,
    );
    _cameraController.initialize().then((value) {
      _isInitialized.value = true;
      _cameraController.startImageStream((image) => _cameraImage = image);
      _isInitialized.refresh();
    }).catchError((Object e) async {
      if (e is CameraException) {
        // todo: deal with disabled permissions
      }
    });
  }

  @override
  void onInit() {
    // automatically called when the controller is first created
    if (!_isInitialized.value) {
      initCamera();
    }
    super.onInit();
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
