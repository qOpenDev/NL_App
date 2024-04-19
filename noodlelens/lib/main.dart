import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'main_camera.dart';

late final CameraDescription camera;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  init();
  runApp(const NoodleLens());
}

Future<void> init() async {
  final cameras = await availableCameras();
  camera = cameras.first;
}

class NoodleLens extends StatelessWidget {
  const NoodleLens({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mainCameraPage = MainCameraPage(camera: camera);

    return MaterialApp(
      title: 'NoodleLens',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: mainCameraPage,
    );
  }
}
