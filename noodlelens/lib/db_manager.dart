import 'dart:io';
import 'dart:convert';

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
  String imagePath = '';
  /// 作り方
  String howToMake = '';
  /// 商品説明
  String instructions = '';
}

class DBManager {
  //データベース名
  static const _databaseName = 'appdb.sqlite3';

  //テーブル名
  static const _noodleDescriptionTable = 'noodle_description';
  static const _noodleItemTable = 'noodle_item';
  //カラム名
  static const _noodleItemImageColumn = 'image';
  static const _noodleItemNameColumn = 'manufacture_name';
  static const _noodleItemCommonIdColumn = 'common_id';
  static const _noodleDescriptionNameColumn = 'name';
  static const _noodleDescriptionLanguageColumn = 'language';
  static const _noodleDescriptionRecipeColumn = 'Recipe';
  static const _noodleDescriptionInstructionsColumn = 'instructions';

  static Database? _database;

  /// コンストラクタ
  ///
  DBManager._init();

  static Future<DBManager> create() async {
    var instance = DBManager._init();
    // _database ??= await _getDatabase();
    if(_database == null) {
      await _getDatabase();
    }
    return instance;
  }

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
  }

  static void _createDatabase(var db) {
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

  static Future<void> _registerData(var db) async {
    const jsonFile = 'assets/db/appdb.json';
    final jsonString = await rootBundle.loadString(jsonFile);
    Map<String, dynamic> items = json.decode(jsonString);

    for(var item in items.values) {
      await db.insert(
        _noodleItemTable,
        {
          'common_id': item['common_id'],
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

  Future<NoodleItem> getNoodleItem(int id, String lang) async {
    // アイテムを検索
    List<Map<String, dynamic>> itemQuery = await _database!.query(
      _noodleItemTable,
      where: 'common_id = ?',
      whereArgs: [id],
    );
    var item = itemQuery[0];
    var commonId = item['common_id'];
    var language = lang;

    // アイテムの翻訳説明文を検索
    List<Map<String, dynamic>> descriptionQuery = await _database!.query(
      _noodleDescriptionTable,
      where: 'item = ? and language = ?',
      whereArgs: [commonId, language],
    );
    var description = descriptionQuery[0];

    var noodleItem =NoodleItem();
    noodleItem.commonId = commonId;
    noodleItem.manufactureNameJp = item['name'];
    noodleItem.manufactureName = description['name'];
    noodleItem.nameJp = item['name'];
    noodleItem.name = description['name'];
    noodleItem.howToMake = description['recipe'];
    noodleItem.instructions = description['instructions'];
    noodleItem.language = language;
    noodleItem.imagePath = _getImage(item['image']);

    return noodleItem;
  }

  String _getImage(var fileName) {
    return join('assets/noodle_images/', fileName);
  }
}


