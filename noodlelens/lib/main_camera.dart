import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'camera_frame.dart';


class MainCameraPage extends StatefulWidget {
  late final CameraDescription camera;

  MainCameraPage({Key? key, required this.camera}) : super(key: key);

  @override
  State<MainCameraPage> createState() => _MainCameraPageState();
}

class _MainCameraPageState extends State<MainCameraPage> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  int? previewHeight;
  int? previewWidth;

  void startDetection(){
    _cameraController.startImageStream((image) async {
      final rowImage = image;
    });
  }

  void stopDetection() {
    _cameraController.stopImageStream();
  }

  @override
  void initState() {
    super.initState();

    _cameraController = CameraController(
      // カメラを指定
      widget.camera,
      // 解像度を定義
      ResolutionPreset.high,
    );

    // コントローラーを初期化
    _initializeControllerFuture = _cameraController.initialize().then((value) {
      var previewSize = _cameraController.value.previewSize;
      previewHeight = previewSize?.height as int;
      previewWidth = previewSize?.width as int;

      //検出の開始
      startDetection();
    });
  }

  @override
  void dispose() {
    // ウィジェットが破棄されたら、コントローラーを破棄
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var cameraBuilder = FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return CameraPreview(_cameraController);
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );

    return CameraFrame(cameraBuilder: cameraBuilder);
  }
}
