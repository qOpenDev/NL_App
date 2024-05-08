import 'package:flutter/material.dart';
import 'package:noodlelens/db_manager.dart';

import 'menu_drawer.dart';
import 'async_init.dart';


class Result extends StatelessWidget {
  Result({Key? key, required this.commonIndex}) : super(key: key);

  late final DBManager _db = AsyncInit.db;
  late final int commonIndex;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      drawer: const Drawer(
        child: MenuDrawer(),
      ),
      body:const Center(
        child: Column(
          children: [
            Text(
              '',
            )
          ],
        ),
      )
    );
  }
}