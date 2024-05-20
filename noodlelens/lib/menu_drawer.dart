import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'debug_screen.dart';


class MenuDrawer extends StatelessWidget {
  const MenuDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          ListTile(
            title: const Text('Language'),
            onTap: () {
              // Do something
            },
          ),
          ListTile(
            title: const Text('DebugScreen'),
            onTap: () => _pushDebugScreen(context),
          )
        ],
      ),
    );
  }

  /// デバッグスクリーンに移動
  ///
  Future<void> _pushDebugScreen(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context){
          return DebugScreen();
        },
      ),
    );
  }
}