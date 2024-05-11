import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';


class ImageConverter {

  static Future<img.Image?> convertToImage(CameraImage cameraImage) async {
    img.Image? image;
    if(cameraImage.format.group == ImageFormatGroup.bgra8888) {
      image = await _convertBGRA8888toUint8List(cameraImage);
    }
    else if(cameraImage.format.group == ImageFormatGroup.yuv420) {
      image = await _convertYuv420ToUint8List(cameraImage);
    }
    else {
      //
    }

    return image;
  }

  // CameraImageからImageへの変換
  //
  static Future<img.Image> _convertBGRA8888toUint8List(CameraImage cameraImage) async {
    final int width = cameraImage.width;
    final int height = cameraImage.height;
    final img.Image image = img.Image(width: width, height: height); // 新しいイメージを作成

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int pixelOffset = (x + y * width) * 4;
        final int blue = cameraImage.planes[0].bytes[pixelOffset];
        final int green = cameraImage.planes[0].bytes[pixelOffset + 1];
        final int red = cameraImage.planes[0].bytes[pixelOffset + 2];
        final int alpha = cameraImage.planes[0].bytes[pixelOffset + 3];
        image.setPixelRgba(x, y, red, green, blue, alpha);
      }
    }

    return image;
  }

  static Future<img.Image> _convertYuv420ToUint8List(CameraImage cameraImage) async {
    final int width = cameraImage.width;
    final int height = cameraImage.height;
    final img.Image image = img.Image(width: width, height: height); // 新しいイメージを作成

    // YUVプレーンの取得
    final Uint8List yPlane = cameraImage.planes[0].bytes;
    final Uint8List uPlane = cameraImage.planes[1].bytes;
    final Uint8List vPlane = cameraImage.planes[2].bytes;

    final int uvRowStride = cameraImage.planes[1].bytesPerRow;
    final int? uvPixelStride = cameraImage.planes[1].bytesPerPixel;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int uvIndex = uvRowStride * (y ~/ 2) + uvPixelStride! * (x ~/ 2);
        final int index = y * width + x;

        final int yp = yPlane[index];
        final int up = uPlane[uvIndex];
        final int vp = vPlane[uvIndex];

        // YUVをRGBに変換
        final num r = (yp + vp * 1436 / 1024 - 179).clamp(0, 255);
        final num g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91).clamp(0, 255);
        final num b = (yp + up * 1814 / 1024 - 227).clamp(0, 255);

        // RGBAに設定
        image.setPixelRgb(x, y, r, g, b);
      }
    }

    return image;
  }
}