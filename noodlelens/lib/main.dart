import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';

import 'camera.dart';
import 'learning_model.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // カメラ
  final cameras = await availableCameras();
  final camera = cameras.first;
  // 推論インタプリタ
  final model = await LearningModel.create();

  // アプリの向きを固定
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(
        NoodleLens(camera: camera, model: model)
    );
  });

  // runApp(
  //     NoodleLens(camera: camera, model: model)
  // );
}

class NoodleLens extends StatelessWidget {
  final CameraDescription camera;
  final LearningModel model;
  late final CameraPage _mainCameraPage;

  NoodleLens({
    Key? key,
    required this.camera,
    required this.model
  }):super(key: key) {
    _mainCameraPage = CameraPage(camera: camera, imageCallback: getImage);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoodleLens',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _mainCameraPage,
    );
  }

  Future<void> getImage(img.Image image) async {
    final result = await model.fit(image);
    final topLabel = result[0]!;
    final debugRealtimeLabel = '${model.labelList[topLabel.index]} ${topLabel.value}%';
    _mainCameraPage.debugRealtimeLabel = debugRealtimeLabel;
  }
}
