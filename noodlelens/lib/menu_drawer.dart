import 'package:flutter/material.dart';


class MenuDrawer extends StatelessWidget {
  const MenuDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Settings'),
          ),
          ListTile(
            title: const Text('Item 1'),
            onTap: () {
              // Do something
            },
          ),
          ListTile(
            title: const Text('Item 2'),
            onTap: () {
              // Do something
            },
          ),
        ],
      ),
    );
  }

}