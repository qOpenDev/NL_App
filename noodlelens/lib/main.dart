import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';

import 'camera.dart';
import 'learning_model.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // アプリの向きを固定
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) async {
    final main = Main();
    await main.camera.cameraState.initialize();
    runApp(main);
  });
}


class Main extends StatelessWidget {
  Main({Key? key}):super(key: key);

  final Camera camera = Camera();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoodleLens',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: camera,
    );
  }
}
