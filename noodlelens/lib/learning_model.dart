import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'dart:math';

import 'debug_screen.dart';


class RecognitionResult {
  /// データベースインデックス
  final int index;
  /// 確率
  final double value;

  RecognitionResult({required this.index, required this.value});
}


class LearningModel {
  /// <h1>コンストラクタ</h1>
  ///
  /// <p>
  /// インスタンスの作成はcreate()から行うこと。
  /// </p>
  LearningModel();

  static const _inputImageSize = 64;
  static const _modelName = 'assets/tflite/vgg16_9types.tflite';
  static const _labelName = 'assets/tflite/vgg16_9types_labels.txt';
  static const _labelSeparator = ',';
  static const _maxLabelCount = 5;
  static final List<RecognitionResult> _invalidResult = [];
  /// 確率を%表示にしたときの小数点以下桁数
  static const _roundingDecimalPointDigits = 2;
  /// 認識可能なラベルの総数
  static const labelCount = 10;

  // 推論モデル
  late Interpreter _model;
  // モデルオプション
  late InterpreterOptions _modelOptions;
  // ラベル(List)
  late List<String> labelList;
  // インタープリタの初期化フラグ
  static var _isModelInitialized = false;



  /// <h1>インスタンス生成</h1>
  static Future<LearningModel> create() async {
    var instance = LearningModel();
    await instance._loadModel();
    await instance._loadLabels();
    // 初期化の終了
    _isModelInitialized = true;
    return instance;
  }

  /// カップ麺の識別
  ///
  Future<List<RecognitionResult>> fit(img.Image image) async {
    if(!_isModelInitialized) {
      return _invalidResult;
    }

    var result = _invalidResult;
    final inputImages = await _CreateImageVariations(image);

    List<List<double>> outputTensorList = List.filled(inputImages.length, List<double>.filled(labelList.length, 0.0));
    try {
      var index = 0;
      for (var image in inputImages) {
        final inputTensor = _convertToTensor(image);
        final outputTensor = [List<double>.filled(labelList.length, 0.0)];

        // インタプリタの実行
        await _run(inputTensor, outputTensor);
        // List<List<double>>からList<double>に変換
        final extracted = outputTensor.first;
        final percentage = _convertToPercentage(extracted);
        outputTensorList[index] = percentage;
        index++;
      }
      // 確率上位のラベルを抽出
      result = _getSelectedLabels(outputTensorList);
    }
    catch(exception) {
      print(exception.toString());
      return _invalidResult;
    }

    // デバッグプリント
    _printLabelToDebug(result);
    // デバッグスクリーン用
    DebugScreen.imageList?.add(inputImages);
    DebugScreen.resultList?.add(result[0]);

    return result;
  }

  /// <h1>推論結果上位のラベルを取得</h1>
  ///
  List<RecognitionResult> _getSelectedLabels(List<List<double>> outputList) {
    final output0 = outputList[0].reduce(max);
    final output1 = outputList[1].reduce(max);
    final output2 = outputList[2].reduce(max);
    List<double>? maxOutput = [];

    if(output0 >= output1) {
      if(output0 >= output2) {
        maxOutput = outputList[0];
      }
    }
    if(output1 >= output2) {
      if(output1 >= output0) {
        maxOutput = outputList[1];
      }
    }
    if(output2 >= output0) {
      if(output2 >= output1) {
        maxOutput = outputList[2];
      }
    }

    final valuesList = maxOutput;
    final valuesMap = <RecognitionResult>[];

    for(var index=0; index < _maxLabelCount; index++) {
      // 最大値とその時のインデックスを取得
      final maxValue = valuesList.reduce(max);
      final maxValueIndex = valuesList.indexOf(maxValue);
      // 最大値を保存
      valuesMap.add(RecognitionResult(index: maxValueIndex, value: maxValue));
      // 最大値を元のリストから削除
      valuesList.removeAt(maxValueIndex);
    }

    return valuesMap;
  }

  List<double> _convertToPercentage(List<double> decimalList) {
    final List<double> percentageList = [];
    for(var decimal in decimalList) {
      final percentageString = (decimal * 100).toStringAsFixed(_roundingDecimalPointDigits);
      final percentage = double.parse(percentageString);
      percentageList.add(percentage);
    }
    return percentageList;
  }

  Future<List<img.Image>> _CreateImageVariations(img.Image image) async {
    // インプットサイズにリサイズして正方形にトリミング
    final square = img.copyResizeCropSquare(image, size: _inputImageSize);
    // サイズに外接する円でトリミング
    const radius = _inputImageSize ~/ 2;
    const cx = _inputImageSize ~/ 2;
    const cy = cx;
    final circled = img.copyCropCircle(square, radius: radius, centerX: cx, centerY: cy);
    final rotate1 = img.copyRotate(circled, angle: -90);
    final rotate2 = img.copyRotate(circled, angle: 90);
    final rotate3 = img.copyRotate(circled, angle: 180);
    return [rotate1, circled, rotate2, rotate3];
  }

  void _printLabelToDebug(List<RecognitionResult> result) {
    final top = result[0];
    print("");
    print(top.value.toString() + "% : " + labelList[top.index]);
  }

  // Future<void> _saveImageToDebug(img.Image image) async {
  //   try {
  //     String? path;
  //     if(Platform.isIOS) {
  //       path = await getApplicationDocumentsDirectory().toString();
  //     }
  //     else if(Platform.isAndroid) {
  //       path = '/data/data/com.qopendev.noodlelens/app_flutter';
  //     }
  //     final dateTime = DateTime.now();
  //     final fileName = DateFormat('yyyyMMddhhmmss${dateTime.millisecond}').format(dateTime) + '.png';
  //     final imagePath = '$path/$fileName';
  //     final imageFile = File(imagePath);
  //     final pngByte = img.encodePng(image);
  //     await imageFile.writeAsBytes(pngByte);
  //   }
  //   catch(ex) {
  //     print('');
  //     print('画像のデバッグ保存に失敗.-------------------------------------------');
  //   }
  // }

  /// 非同期でインタープリタの実行
  /// 
  Future<void> _run(Object input, Object output) async {
    _model.run(input, output);
  }

  /// <h1>推論モデルのロード</h1>
  ///
  Future<void> _loadModel() async {
    _modelOptions = InterpreterOptions();
    _modelOptions.threads = 1;
    _model = await Interpreter.fromAsset(_modelName, options: _modelOptions);
  }

  /// <h1>推論モデルのラベルのロード</h1>
  ///
  Future<void> _loadLabels() async {
    final labelString = await rootBundle.loadString(_labelName);
    final rawLabel = labelString.split(_labelSeparator);
    // 空文字列を除去
    final label = rawLabel.where((n) => n != '').toList();
    
    labelList = label;
  }

  List<List<List<List<num>>>> _convertToTensor(img.Image image) {
    final imageMatrix = List.generate(
      1,
      (index) {
        return List.generate(
          image.height,
          (y) => List.generate(
            image.width,
            (x) {
              final pixel = image.getPixel(x, y);
              return [pixel.r / 255.0, pixel.g / 255.0, pixel.b / 255.0];
            }
          )
        );
      }
    );
    return imageMatrix;
  }

  Future<void> dispose() async {
    _model.close();
  }
}