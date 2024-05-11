import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'db_manager.dart';
import 'learning_model.dart';

class AsyncInit {
  AsyncInit._();

  /// カメラコントローラ
  static late CameraController _cameraController;
  /// カメラコントローラ
  static CameraController get cameraController => _cameraController;
  /// カメラの初期化判断フラグ
  static late Future<bool> _initializeControllerFuture;
  /// カメラの初期化判断フラグ
  static Future<bool> get initializeControllerFuture => _initializeControllerFuture;

  /// データベースマネージャ
  static late DBManager _db;
  /// データベースマネージャ
  static DBManager get db => _db;

  /// 推論モデル
  static late final LearningModel _model;
  /// 推論モデル
  static LearningModel get model => _model;

  static Future<bool> initialize() async {
    // カメラ初期化
    // 後にFutureBuilderにて処理待ちするからここでawaitしない
    _initializeControllerFuture = _initializeCamera();

    // データベース初期化
    _db = await DBManager.create();

    // 認識モデル作成
    _model = await LearningModel.create();

    return true;
  }

  static Future<bool> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = cameras.first;

    // カメラコントローラ取得
    _cameraController = CameraController(
      // カメラを指定
      camera,
      // 解像度を定義
      ResolutionPreset.high,
      //マイクへのアクセス禁止
      enableAudio: false,
    );

    // カメラ初期化
    await _cameraController.initialize();
    // カメラ向きを固定
    await _cameraController.lockCaptureOrientation(
      DeviceOrientation.portraitUp,
    );

    return true;
  }
  
  static Future<void> dispose() async {
    await _db.dispose();
    await _cameraController.dispose();
    await _model.dispose();
  }
}