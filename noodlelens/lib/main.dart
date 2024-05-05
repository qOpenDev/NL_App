import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';

import 'camera.dart';
import 'learning_model.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Future<void> create() async {
    final main = Main();
    await main.initialize();

    runApp(
        main
    );
  }

  // アプリの向きを固定
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) => create());
}

class CommonData {
  /// リアルタイム画像取得の最大数
  final maxHistory = 10;
  /// 認識開始フラグ
  var startRecognition = false;
  /// trueでデバッグ用認識
  var debugRecognition = false;
  ///
  var isCameraActive = false;
}

class Main extends StatelessWidget {
  /// デバッグ用認識タイマー間隔
  static const _debugRecognitionTimerDuration = 500;

  /// 推論モデル
  late final LearningModel _model;
  /// カメラウィジェット
  late final CameraPage _cameraPage;

  /// 直前までの取得画像リスト
  final images = <img.Image>[];
  /// 共通データクラス
  final common = CommonData();

  /// デバッグ用認識タイマー
  late final Timer _debugRecognitionTimer;

  Main({Key? key}):super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoodleLens',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(''),
        ),
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
        body: GestureDetector(
          onTap: () => common.startRecognition = true,
          child: _cameraPage,
        )
      ),
    );
  }

  Future<void> initialize() async {
    // カメラ初期化
    _cameraPage = CameraPage();
    await _cameraPage.state.initializeCamera();
    _cameraPage.state.imageCallback = onCaptureImage;
    // 推論インタプリタ初期化
    _model = await LearningModel.create();

    //デバッグタイマースタート
    _debugRecognitionTimer = Timer.periodic(
      const Duration(
        milliseconds: _debugRecognitionTimerDuration,
      ),
      (timer) => common.debugRecognition = true,
    );
  }

  Future<void> onCaptureImage(img.Image image) async {
    //取得画像を保存
    if(images.length >= common.maxHistory) {
      images.removeLast();
    }
    images.insert(0, image);

    // ユーザによる認識の指示
    if(common.startRecognition) {
      // 認識
      final index = await recognition();
      _cameraPage.state.debugLabel = _model.labelList[index];
      common.startRecognition = false;
    }
    // デバッグ用のリアルタイム認識
    else if(common.debugRecognition) {
      final result = await _model.fit(image);
      final topLabel = result[0];
      final debugRealtimeLabel = '${_model.labelList[topLabel.index]} ${topLabel.value}%';
      _cameraPage.state.debugRealtimeLabel = debugRealtimeLabel;

      common.debugRecognition = false;
    }
  }

  void onTappedCameraPreview() {
    common.startRecognition = true;
  }

  Future<int> recognition() async {
    final resultList = <NoodleLabel>[];
    for(final image in images) {
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
