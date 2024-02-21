import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NoodleLens',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainCameraPage(title: 'NoodleLens'),
    );
  }
}

class MainCameraPage extends StatefulWidget {
  const MainCameraPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MainCameraPage> createState() => _MainCameraPageState();
}

class _MainCameraPageState extends State<MainCameraPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Text(
              'Add first NoodleLens page.',
            ),
          ],
        ),
      ),
    );
  }
}
