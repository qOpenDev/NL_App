import 'package:flutter/material.dart';
import 'dart:io';

import 'db_manager.dart';
import 'menu_drawer.dart';
import 'async_init.dart';
import 'noodle_item.dart';
import 'config.dart';
import 'description.dart';


class RecognitionResult extends StatelessWidget {
  RecognitionResult({Key? key}) : super(key: key);

  static const ok = 1;
  static const cancel = 2;
  static const otherCandidates = 0;

  // データベース
  late final DBManager _db = AsyncInit.db;

  @override
  Widget build(BuildContext context) {
    var gettingNoodleItemFuture = _getNoodleItem();
    var noodleItem = NoodleItem();

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        leading: IconButton(
          icon: Platform.isIOS ? const Icon(Icons.arrow_back_ios) : const Icon(Icons.arrow_back),
          onPressed: () => _close(context, cancel),
        ),
      ),
      endDrawer: const Drawer(
        child: MenuDrawer(),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Center(
              child: Column(
                children: [
                  FutureBuilder(
                    future: gettingNoodleItemFuture,
                    builder:(context, snapshot) {
                      if(snapshot.connectionState == ConnectionState.done) {
                        noodleItem = snapshot.data as NoodleItem;
                        return Center(
                          child: Column(
                            children: <Widget>[
                              Text(
                                noodleItem.name,
                                style: const TextStyle(
                                  fontSize: 32,
                                ),
                              ),
                              Image.asset(
                                'assets/noodle_images/${noodleItem.imagePath}',
                                fit: BoxFit.fitWidth,
                              ),
                            ],
                          ),
                        );
                      }
                      else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () => _close(context, ok, noodleItem),
                        child: const Text(
                          'Next'
                        )
                      ),
                      ElevatedButton(
                        onPressed: () => _close(context, otherCandidates),
                        child: const Text(
                          'Other candidates'
                        )
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      )
    );
  }

  Future<NoodleItem> _getNoodleItem() async {
    var item = await _db.getNoodleItem(Config.commonIndex, Config.language);
    return item;
  }

  /// 結果表示のページに遷移
  ///
  void _close(BuildContext context, int state, [NoodleItem? item]) {
    final result = {
      'state': state,
      'item': item,
    };
    Navigator.pop(context, result);
  }
}