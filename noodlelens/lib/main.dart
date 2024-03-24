import 'package:flutter/material.dart';
import 'db_manager.dart';

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
  DBManager? _dbManager;

  @override
  Widget build(BuildContext context) {
    _createDB();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Add first NoodleLens page.',
            ),
            ElevatedButton(
                onPressed: _onTestButtonPressed,
                child: const Text('データベース'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createDB() async {
    _dbManager = await DBManager.create();
  }

  void _onTestButtonPressed() async {;
    var item = await _dbManager!.getNoodleItem(1, NoodleItem.EN);
    print('');
  }
}
