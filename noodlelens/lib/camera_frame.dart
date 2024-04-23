import 'package:flutter/material.dart';

class CameraFrame extends Scaffold {
  final String title = '';
  final FutureBuilder<void> cameraBuilder;

  /// コンストラクタ
  ///
  CameraFrame({
    Key? key,
    required this.cameraBuilder,
  }) : super(key: key);

  /// アプリケーションバー
  ///
  @override
  PreferredSizeWidget? get appBar {
    return AppBar(title: Text(title));
  }

  /// ドロワー
  ///
  @override
  Widget? get drawer {
    return Drawer(
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
    );
  }

  /// カメラプレビュー表示
  ///
  @override
  Widget? get body {
    return Center(
      child: Stack(
        children: [
          //TODO こいつ動いてない
          Container(
            height: 300,
            width: 300,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green, width:5),
              shape: BoxShape.circle
            ),
          ),
          cameraBuilder,
        ],
      ),
    );
  }
}