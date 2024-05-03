import 'package:flutter/material.dart';
import 'package:native_device_orientation/native_device_orientation.dart';

// class CameraFrame extends Scaffold {
//   /// カメラか取得した画像の回転角度
//   static int deviceRotateDegree = 0;
//   ///
//   final String title = '';
//   ///
//   late final FutureBuilder<void> _cameraBuilder;
//   set cameraBuilder(FutureBuilder<void> builder) {
//     _cameraBuilder = builder;
//   }
//   /// カメラプレビューのサイズ
//   late final _previewSize;
//   set previewSize(Size size) {
//     _previewSize = size;
//   }
//
//   /// コンストラクタ
//   ///
//   CameraFrame({
//     Key? key,
//   }) : super(key: key);
//
//   /// アプリケーションバー
//   ///
//   @override
//   PreferredSizeWidget? get appBar {
//     return AppBar(title: Text(title));
//   }
//
//   /// ドロワー
//   ///
//   @override
//   Widget? get drawer {
//     return Drawer(
//       child:ListView(
//         children: <Widget>[
//           const DrawerHeader(
//             decoration: BoxDecoration(
//               color: Colors.blue,
//             ),
//             child: Text('Settings'),
//           ),
//           ListTile(
//             title: const Text('Item 1'),
//             onTap: () {
//               // Do something
//             },
//           ),
//           ListTile(
//             title: const Text('Item 2'),
//             onTap: () {
//               // Do something
//             },
//           ),
//         ],
//       )
//     );
//   }
//
//   /// カメラプレビュー表示
//   ///
//   @override
//   Widget? get body {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final width = constraints.maxWidth;
//         final height = constraints.maxHeight;
//         return Center(
//           child: Column(
//             // mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Stack(
//                 children: [
//                   _cameraBuilder,
//                   CustomPaint(
//                     size: Size(width, height),
//                     painter: CameraViewPainter(),
//                     // child: Container(),
//                   ),
//                 ],
//               ),
//               Container(
//                 color: Colors.lightBlue,
//               )
//             ],
//           ),
//         );
//       },
//     );
//   }
// }


class CameraViewPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width * 0.9) / 2;
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}