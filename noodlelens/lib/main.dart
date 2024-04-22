import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'main_camera.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();
  final camera = cameras.first;

  runApp(NoodleLens(camera: camera));
}

class NoodleLens extends StatelessWidget {
  final CameraDescription camera;

  const NoodleLens({Key? key, required this.camera}) : super(key: key);

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
