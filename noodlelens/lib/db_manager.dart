import 'dart:io';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';


class NoodleItem {
  //言語
  static const EN = 'en';
  static const ZHS = 'zhs';
  static const ZHT = 'zht';
  static const KO = 'ko';

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
  Image? image;
  /// 作り方
  String howToMake = '';
  /// 商品説明
  String instructions = '';
}

class DBManager {
  /// コンストラクタ
  ///
  DBManager._init();

  // データベース名
  static const _databaseName = 'appdb.sqlite3';
  // テーブル名
  static const _noodleDescriptionTable = 'noodle_description';
  static const _noodleItemTable = 'noodle_item';
  // noodle_item カラム名
  static const _noodleItemName = 'name';
  static const _noodleItemImage = 'image';
  static const _noodleItemManufactureName = 'manufacture_name';
  static const _noodleItemCommonId = 'common_id';
  // noodle_description カラム名
  static const _noodleDescriptionName = 'name';
  static const _noodleDescriptionManufactureName = 'manufacture_name';
  static const _noodleDescriptionLanguage = 'language';
  static const _noodleDescriptionRecipe = 'recipe';
  static const _noodleDescriptionInstructions = 'instructions';

  static Database? _database;
  static int _count = -1;
  static const String _imagePath = 'assets/noodle_images/';


  static Future<DBManager> create() async {
    var instance = DBManager._init();
    if(_database == null) {
      await _getDatabase();
    }
    return instance;
  }

  ///
  /// データベースインスタンスを生成
  ///
  static Future<void> _getDatabase() async {
    // データベースの取得
    _database = await openDatabase(
      _databaseName,
      version: 1,
      onCreate: (db, version) {
        // テーブルの作成
        _createDatabase(db);
        // データの登録
        _registerData(db);
      }
    );
    _getItemCount();
  }

  ///
  /// データベースの作成
  ///
  /// アプリの初回起動時、データベースが存在しないときにのみ呼ばれる。
  ///
  static void _createDatabase(Database db) {
    // アイテムテーブル
    db.execute(
      'CREATE TABLE IF NOT EXISTS noodle_item ('
      '  id INTEGER PRIMARY KEY,'
      '  common_id INTEGER,'
      '  name TEXT,'
      '  image TEXT,'
      '  manufacture_name TEXT);'
    );
    // 翻訳文テーブル
    db.execute(
      'CREATE TABLE IF NOT EXISTS noodle_description ('
      '  id INTEGER PRIMARY KEY,'
      '  item INTEGER REFERENCES noodle_item(id),'
      '  name TEXT,'
      '  language TEXT,'
      '  recipe TEXT,'
      '  instructions TEXT);'
    );
  }

  ///
  /// データベースにテータを登録
  ///
  /// データ元となるJsonファイルから値を読み込んで登録する。
  ///
  static Future<void> _registerData(Database db) async {
    const jsonFile = 'assets/db/appdb.json';
    final jsonString = await rootBundle.loadString(jsonFile);
    Map<String, dynamic> items = json.decode(jsonString);

    for(var item in items.values) {
      await db.insert(
        _noodleItemTable,
        {
          'common_id': item[_noodleItemCommonId],
          'name': item['name'],
          'image': item['image'],
          'manufacture_name': item['manufacture_name'],
        },
      );
      for(var description in item['description_list']) {
        await db.insert(
          _noodleDescriptionTable,
          {
            'item': item['common_id'],
            'name': description['name'],
            'language': description['language'],
            'recipe': description['recipe'],
            'instructions': description['instructions'],
          },
        );
      }
    }
  }

  ///
  /// データベースに登録されているデータ数を取得
  ///
  static Future<void> _getItemCount() async {
    var countQuery = await _database!.rawQuery('SELECT COUNT(*) FROM $_noodleItemTable');
    // _count = countQuery[0] as int;
  }

  ///
  /// カップ麺の情報を取得
  ///
  /// [id]はAIモデルから出力された値を指定、[lang]は出力する言語で`NoodleItem`の定数で指定する。
  /// [id]が存在しない場合は例外を返す。
  ///
  Future<NoodleItem> getNoodleItem(int id, String lang) async {
    // アイテムを検索
    List<Map<String, dynamic>> itemQuery = await _database!.query(
      _noodleItemTable,
      where: 'common_id = ?',
      whereArgs: [id],
    );
    if(itemQuery.isEmpty) {
      throw Exception('指定されたidが存在しません.');
    }
    var item = itemQuery[0];
    var commonId = item[_noodleItemCommonId];

    // アイテムの翻訳説明文を検索
    List<Map<String, dynamic>> descriptionQuery = await _database!.query(
      _noodleDescriptionTable,
      where: 'item = ? and language = ?',
      whereArgs: [commonId, lang],
    );
    if(descriptionQuery.isEmpty) {
      // throw Exception('指定されたidでの翻訳文が存在しません.');
      return NoodleItem();
    }
    var description = descriptionQuery[0];

    var noodleItem = NoodleItem();
    // noodle_item
    noodleItem.commonId = commonId;
    noodleItem.nameJp = item[_noodleItemName];
    noodleItem.manufactureNameJp = item[_noodleItemName];
    noodleItem.image = _getImage(item[_noodleItemImage]);
    // noodle_description
    noodleItem.name = description[_noodleDescriptionName];
    // noodleItem.manufactureName = description[_noodleDescriptionManufactureName];
    noodleItem.language = lang;
    noodleItem.howToMake = description[_noodleDescriptionRecipe];
    noodleItem.instructions = description[_noodleDescriptionInstructions];

    return noodleItem;
  }

  Image _getImage(var fileName) {
    var imagePath = join(_imagePath, fileName);
    return Image(image: AssetImage(imagePath));
  }
}


