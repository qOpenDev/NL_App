import 'package:image/image.dart' as img;

class NoodleItem {
  /// 識別ナンバー
  int commonId = -1;
  /// 翻訳言語
  String language = '';
  /// 商品名(和)
  String nameJp = '';
  /// 商品名
  String name = '';
  /// メーカー(和)
  String manufactureNameJp = '';
  /// メーカー
  String manufactureName = '';
  /// ラベルイメージのパス
  String imagePath = '';
  /// 作り方
  String howToMake = '';
  /// 商品説明
  String instructions = '';
}