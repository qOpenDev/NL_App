import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';

import 'camera.dart';
import 'learning_model.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 推論インタプリタ
  final model = await LearningModel.create();

  Future<void> create() async {
    final main = Main(model: model);
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
  final LearningModel model;
  late final CameraPage _cameraPage;

  Main({
    Key? key,
    // required this.camera,
    required this.model
  }):super(key: key) {
  }

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
    _cameraPage = CameraPage(imageCallback: getImage);
    await _cameraPage.cameraPageState.initializeCamera();
  }

  Future<void> getImage(img.Image image) async {
    final result = await model.fit(image);
    final topLabel = result[0]!;
    final debugRealtimeLabel = '${model.labelList[topLabel.index]} ${topLabel.value}%';
    _cameraPage.debugRealtimeLabel = debugRealtimeLabel;
  }
}
