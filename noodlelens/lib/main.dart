import 'dart:async';

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

class Main extends StatelessWidget {
  late final LearningModel _model;
  late final CameraPage _cameraPage;

  Main({Key? key}):super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoodleLens',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _cameraPage,
    );
  }

  Future<void> initialize() async {
    // カメラ初期化
    _cameraPage = CameraPage(imageCallback: getImage);
    await _cameraPage.cameraPageState.initializeCamera();
    // 推論インタプリタ初期化
    _model = await LearningModel.create();
  }

  Future<void> getImage(img.Image image) async {
    final result = await _model.fit(image);
    final topLabel = result[0]!;
    final debugRealtimeLabel = '${_model.labelList[topLabel.index]} ${topLabel.value}%';
    _cameraPage.debugRealtimeLabel = debugRealtimeLabel;
  }
}
