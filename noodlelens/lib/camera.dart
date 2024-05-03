import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'dart:async';

import 'camera_frame.dart';


class CameraPage extends StatefulWidget {
  late final CameraDescription camera;
  // 画像を取得したときのコールバック
  final Function(img.Image) imageCallback;

  final _cameraPageState = _CameraPageState();

  // デバッグ用
  // var _debugPrint = '';

  set debugRealtimeLabel(value) {
    _cameraPageState.debugRealtimeLabel = value;
    _cameraPageState.invalidate();
  }

  set debugLabel(value) {
    _cameraPageState.debugLabel = value;
    _cameraPageState.invalidate();
  }

  CameraPage({
    Key? key,
    required this.camera,
    required this.imageCallback
  }) : super(key: key);

  @override
  State<CameraPage> createState() => _cameraPageState;
}

class _CameraPageState extends State<CameraPage> {
  /// タイマー間隔ミリ秒
  static const _timerDuration = 1000;
  ///
  static const fixedPreviewRatio = 4.0 / 3.0;

  // 現在のフレーム数
  //int _currentFrameCount = 0;
  // カメラコントローラ
  late CameraController _cameraController;
  // カメラの初期化判断フラグ
  late Future<bool> _initializeControllerFuture;
  // trueで画像のフレーム取得
  var _takePicture = false;
  // カメラプレビューサイズ
  late final Size previewSize;

  // タイマー
  late Timer _timer;

  var debugRealtimeLabel = '';
  var debugLabel = '';

  @override
  void initState() {
    super.initState();

    _cameraController = CameraController(
      // カメラを指定
      widget.camera,
      // 解像度を定義
      ResolutionPreset.high,
      //マイクへのアクセス禁止
      enableAudio: false,
    );

    // コントローラーを初期化
    _initializeControllerFuture = _cameraController.initialize().then((value) {
      _cameraController.lockCaptureOrientation(
        DeviceOrientation.portraitUp,
      );

      final cameraValue = _cameraController.value;
      previewSize = cameraValue.previewSize!;

      //検出の開始
      startDetection();
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('')),
      drawer: Drawer(
        child:ListView(
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Settings'),
            ),
            ListTile(
              title: const Text('Item 1'),
              onTap: () {
                // Do something
              },
            ),
            ListTile(
              title: const Text('Item 2'),
              onTap: () {
                // Do something
              },
            ),
          ],
        )
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxHeight = constraints.maxHeight;
          final maxWidth = constraints.maxWidth;
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 FutureBuilder<void>(
                    future: _initializeControllerFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        final previewWidth = maxWidth;
                        final previewHeight = fixedPreviewRatio * maxWidth;
                        // カメラプレビューとフレームを重ねて表示
                        return Stack(
                          children: [
                            // カメラプレビューサイズをアスペクト比で固定
                            AspectRatio(
                              aspectRatio: 1 / fixedPreviewRatio,
                              child: ClipRect(
                                child: Transform.scale(
                                  scale: _cameraController.value.aspectRatio,
                                  child: Center(
                                    child: AspectRatio(
                                      aspectRatio: 1 / _cameraController.value.aspectRatio,
                                      child: CameraPreview(_cameraController),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            CustomPaint(
                              size: Size(previewWidth, previewHeight),
                              foregroundPainter: CameraViewPainter(),
                            )
                          ],
                        );
                      }
                      else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    }
                ),
                // デバッグ用リアルタイム認識結果
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'リアルタイム検出：',
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      debugRealtimeLabel,
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
                // デバッグ用リアルタイム認識結果
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ユーザ検出：',
                      textAlign: TextAlign.start,
                    ),
                    Text(
                      debugLabel,
                      textAlign: TextAlign.end,
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    stopDetection();
    // ウィジェットが破棄されたら、コントローラーを破棄
    _cameraController.dispose();
    super.dispose();
  }

  void invalidate() {
    setState(() {
      //
    });
  }

  /// 検出の開始
  ///
  Future<void> startDetection() async {
    // カメラのフレーム取得スタート
    _cameraController.startImageStream(getImageByStream);

    // インターバルタイマースタート
    _timer = Timer.periodic(
      const Duration(
        milliseconds: _timerDuration,
      ),
      // フラグを立ててカメラ画像取得
      (timer) => _takePicture = true,
    );
  }

  /// 検出の停止
  ///
  void stopDetection() {
    _timer.cancel();
  }

  Future<void> getImageByStream(CameraImage cameraImage) async {
    if(_takePicture) {
      // CameraImageからImageに変換
      final image = await _convertToImage(cameraImage);
      //コールバック
      widget.imageCallback(image!);

      _takePicture = false;
    }
  }

  Future<img.Image?> _convertToImage(CameraImage cameraImage) async {
    img.Image? image;
    if(cameraImage.format.group == ImageFormatGroup.bgra8888) {
      image = await _convertBGRA8888toUint8List(cameraImage);
    }
    else if(cameraImage.format.group == ImageFormatGroup.yuv420) {
      image = await _convertYuv420ToUint8List(cameraImage);
    }
    else {
      //
    }

    return image;
  }

  // CameraImageからImageへの変換
  //
  Future<img.Image> _convertBGRA8888toUint8List(CameraImage cameraImage) async {
    final int width = cameraImage.width;
    final int height = cameraImage.height;
    final img.Image image = img.Image(width: width, height: height); // 新しいイメージを作成

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int pixelOffset = (x + y * width) * 4;
        final int blue = cameraImage.planes[0].bytes[pixelOffset];
        final int green = cameraImage.planes[0].bytes[pixelOffset + 1];
        final int red = cameraImage.planes[0].bytes[pixelOffset + 2];
        final int alpha = cameraImage.planes[0].bytes[pixelOffset + 3];
        image.setPixelRgba(x, y, red, green, blue, alpha);
      }
    }

    return image;
  }

  Future<img.Image> _convertYuv420ToUint8List(CameraImage cameraImage) async {
    final int width = cameraImage.width;
    final int height = cameraImage.height;
    final img.Image image = img.Image(width: width, height: height); // 新しいイメージを作成

    // YUVプレーンの取得
    final Uint8List yPlane = cameraImage.planes[0].bytes;
    final Uint8List uPlane = cameraImage.planes[1].bytes;
    final Uint8List vPlane = cameraImage.planes[2].bytes;

    final int uvRowStride = cameraImage.planes[1].bytesPerRow;
    final int? uvPixelStride = cameraImage.planes[1].bytesPerPixel;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int uvIndex = uvRowStride * (y ~/ 2) + uvPixelStride! * (x ~/ 2);
        final int index = y * width + x;

        final int yp = yPlane[index];
        final int up = uPlane[uvIndex];
        final int vp = vPlane[uvIndex];

        // YUVをRGBに変換
        final num r = (yp + vp * 1436 / 1024 - 179).clamp(0, 255);
        final num g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91).clamp(0, 255);
        final num b = (yp + up * 1814 / 1024 - 227).clamp(0, 255);

        // RGBAに設定
        image.setPixelRgb(x, y, r, g, b);
      }
    }

    return image;
  }
}
