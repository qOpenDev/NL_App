import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'dart:async';

import 'camera_frame.dart';


class CameraPage extends StatefulWidget {
  late final CameraDescription camera;

  final _cameraPageState = _CameraPageState();
  /// CameraPageのStateクラスインスタンス
  get state => _cameraPageState;

  CameraPage({Key? key}) : super(key: key);

  @override
  State<CameraPage> createState() => _cameraPageState;
}

class _CameraPageState extends State<CameraPage> {
  /// 画像キャプチャタイマー間隔
  static const _captureTimerDuration = 100;
  /// カメラプレビューのアスペクト比
  static const _fixedPreviewRatio = 4.0 / 3.0;


  /// 画像を取得したときのコールバック
  late final Function(img.Image) imageCallback;
  /// カメラコントローラ
  late CameraController _cameraController;
  /// カメラの初期化判断フラグ
  late Future<bool> _initializeControllerFuture;
  /// trueで画像のフレーム取得
  var _takePicture = false;
  /// カメラプレビューサイズ
  late final Size previewSize;

  /// 画像キャプチャタイマー
  late Timer? _captureTimer;

  var _debugRealtimeLabel = '';
  set debugRealtimeLabel(value) {
    _debugRealtimeLabel = value;
    invalidate();
  }

  var _debugLabel = '';
  set debugLabel(value) {
    _debugLabel = value;
    invalidate();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
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
                      final previewHeight = _fixedPreviewRatio * maxWidth;

                      // 検出の開始
                      if(!_cameraController.value.isStreamingImages) {
                        resumeDetection();
                      }

                      // カメラプレビューとフレームを重ねて表示
                      return Stack(
                        children: [
                          // カメラプレビューサイズをアスペクト比で固定
                          AspectRatio(
                            aspectRatio: 1 / _fixedPreviewRatio,
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
                    'RealTime :',
                    textAlign: TextAlign.start,
                  ),
                  Text(
                    _debugRealtimeLabel,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              // デバッグ用リアルタイム認識結果
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'User :',
                    textAlign: TextAlign.start,
                  ),
                  Text(
                    _debugLabel,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    suspendDetection();
    // ウィジェットが破棄されたら、コントローラーを破棄
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;

    _cameraController = CameraController(
      // カメラを指定
      camera,
      // 解像度を定義
      ResolutionPreset.high,
      //マイクへのアクセス禁止
      enableAudio: false,
    );

    // コントローラーを初期化
    _initializeControllerFuture = _initializeCameraController();
  }

  /// カメラコントローラを初期化
  ///
  Future<bool> _initializeCameraController() async {
    await _cameraController.initialize();
    await _cameraController.lockCaptureOrientation(
      DeviceOrientation.portraitUp,
    );

    final cameraValue = _cameraController.value;
    previewSize = cameraValue.previewSize!;

    return true;
  }

  /// ページを再描画
  ///
  void invalidate() {
    setState(() {
      //
    });
  }

  /// 検出の再開
  ///
  Future<void> resumeDetection() async {
    _cameraController.startImageStream(getImageByStream);
    // タイマー初期化
    _captureTimer = Timer.periodic(
      const Duration(
        milliseconds: _captureTimerDuration,
      ),
      // フラグを立ててカメラ画像取得
      (timer) => _takePicture = true,
    );
  }

  /// 検出の停止
  ///
  void suspendDetection() {
    _captureTimer?.cancel();
    _cameraController.stopImageStream();
  }

  Future<void> getImageByStream(CameraImage cameraImage) async {
    if(_takePicture) {
      // CameraImageからImageに変換
      final image = await _convertToImage(cameraImage);
      //コールバック
      imageCallback(image!);

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
