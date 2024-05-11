import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noodlelens/async_init.dart';

import 'camera.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 非同期で初期化処理
  await AsyncInit.initialize();

  // アプリの向きを固定
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) async {
    runApp(Main());
  });
}


class Main extends StatelessWidget {
  Main({Key? key}):super(key: key);

  final Camera camera = Camera();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: camera,
    );
  }
}
