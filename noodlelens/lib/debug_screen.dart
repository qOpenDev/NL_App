import 'dart:core';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import 'learning_model.dart';
import 'async_init.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({Key? key,}) : super(key: key);

  /// 直前までの取得画像リスト
  static List<List<img.Image>>? imageList = [];
  /// _imageHistoryの認識結果
  static List<RecognitionResult>? resultList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: ListView(
        children: createResultList(),
      )
    );
  }

  List<Widget> createResultList() {
    var rows = <Widget>[];

    var index = 0;
    for(final images in imageList!) {
      final imagesInRow = <Widget>[];
      for(final image in images) {
        final imageWidget = _image2ImageWidget(image);
        imagesInRow.add(imageWidget);
      }
      final row = Row(
        children: imagesInRow,
      );
      rows.add(row);

      final result = resultList?[index];
      final label = AsyncInit.model.labelList[result!.index];
      final resultString = '$index.$label ${result.value}%';
      final text = Text(resultString);
      rows.add(text);
    }

    return rows;
  }

  Widget _image2ImageWidget(img.Image image) {
    List<int> png = img.encodePng(image);
    final array = Uint8List.fromList(png);
    final imageWidget = Image.memory(array);

    final container = Container(
      margin: const EdgeInsets.all(10),
      child: imageWidget,
    );

    return container;
  }
}