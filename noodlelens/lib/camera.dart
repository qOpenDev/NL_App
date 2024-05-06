import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'dart:async';

import 'learning_model.dart';
import 'image_converter.dart';
import 'camera_painter.dart';
import 'menu_drawer.dart';


class Camera extends StatefulWidget {
  Camera({Key? key}) : super(key: key) ;

  final cameraState = CameraState();

  @override
  State<Camera> createState() => cameraState;
}


class CameraState extends State<Camera> {
  /// 画像キャプチャタイマー間隔
  static const _captureTimerDuration = 100;
  /// カメラプレビューのアスペクト比
  static const _fixedPreviewRatio = 4.0 / 3.0;

  /// デバッグ用認識タイマー間隔
  static const _debugRecognitionTimerDuration = 500;

  /// 推論モデル
  late final LearningModel _model;

  /// 直前までの取得画像リスト
  final _imageHistory = <img.Image>[];

  /// 画像キャプチャタイマー
  Timer? _captureTimer;
  /// デバッグ用認識タイマー
  Timer? _debugRecognitionTimer;

  /// カメラコントローラ
  late CameraController _cameraController;
  /// カメラの初期化判断フラグ
  late Future<bool> _initializeControllerFuture;
  /// trueで画像のフレーム取得
  var _takePicture = false;

  /// リアルタイム画像取得の最大数
  final _maxImageHistory = 10;
  /// 認識開始フラグ
  var _startRecognition = false;
  /// trueでデバッグ用認識
  var _debugRecognition = false;

  var _debugRealtimeLabel = '';
  var _debugLabel = '';


  Future<void> initialize() async {
    // カメラ初期化
    _initializeControllerFuture = _initializeCamera();

    // タイマースタート
    _startTimer();

    // 認識モデル作成
    _model = await LearningModel.create();
  }

  Future<bool> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;

    // カメラコントローラ取得
    _cameraController = CameraController(
      // カメラを指定
      camera,
      // 解像度を定義
      ResolutionPreset.high,
      //マイクへのアクセス禁止
      enableAudio: false,
    );

    // カメラ初期化
    await _cameraController.initialize();
    // カメラ向きを固定
    await _cameraController.lockCaptureOrientation(
      DeviceOrientation.portraitUp,
    );

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      drawer: const Drawer(
        child: MenuDrawer(),
      ),
      body: GestureDetector(
        onTap: () => _startRecognition = true,
        child: LayoutBuilder(
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
                            _cameraController.startImageStream(_getImageByStream);
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
        ),
      )
    );
  }

  @override
  void dispose() {
    _captureTimer?.cancel();
    _cameraController.stopImageStream();
    _cameraController.dispose();
    _stopTimer();
    super.dispose();
  }

  /// 一定間隔で画像をキャプチャするためのタイマーをスタート
  ///
  void _startTimer() {
    // 画像キャプチャ用タイマー
    _captureTimer ??= Timer.periodic(
      const Duration(
        milliseconds: _captureTimerDuration,
      ),
      // フラグを立ててカメラ画像取得
      (timer) => _takePicture = true,
    );

    // デバッグ認識用タイマー
    _debugRecognitionTimer ??= Timer.periodic(
      const Duration(
        milliseconds: _debugRecognitionTimerDuration,
      ),
      (timer) => _debugRecognition = true,
    );
  }

  /// タイマーを停止
  ///
  void _stopTimer() {
    _captureTimer?.cancel();
    _captureTimer = null;

    _debugRecognitionTimer?.cancel();
    _debugRecognitionTimer = null;
  }

  Future<void> _getImageByStream(CameraImage cameraImage) async {
    if(!_takePicture) {
      // タイマーがフラグを変えたときのみ処理
      return ;
    }

    // CameraImageからImageに変換
    final image = await ImageConverter.convertToImage(cameraImage);

    // 古い画像を削除
    if(_imageHistory.length >= _maxImageHistory) {
      _imageHistory.removeLast();
    }
    //取得画像を保存
    _imageHistory.insert(0, image!);

    // ユーザによる認識の指示
    if(_startRecognition) {
      // 認識
      final index = await _recognition();
      setState(() {
        _debugLabel = _model.labelList[index];
      });
      _startRecognition = false;
    }
    // デバッグ用のリアルタイム認識
    else if(_debugRecognition) {
      final result = await _model.fit(image);
      final topLabel = result[0];
      setState(() {
        _debugRealtimeLabel = '${_model.labelList[topLabel.index]} ${topLabel.value}%';
      });

      _debugRecognition = false;
    }

    _takePicture = false;
  }

  Future<int> _recognition() async {
    final resultList = <NoodleLabel>[];
    for(final image in _imageHistory) {
      final result = await _model.fit(image);
      resultList.add(result[0]);
    }

    final rank = List<int>.filled(LearningModel.labelCount, 0);
    for(final label in resultList) {
      rank[label.index] += 1;
    }
    final maxCount = rank.reduce(max);
    final index = rank.indexOf(maxCount);
    return index;
  }
}