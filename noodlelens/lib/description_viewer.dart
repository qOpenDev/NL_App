import 'package:flutter/material.dart';

import 'menu_drawer.dart';
import 'noodle_item.dart';


class DescriptionViewer extends StatelessWidget {
  const DescriptionViewer({Key? key, required this.noodleItem}) : super(key: key);

  final NoodleItem noodleItem;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      endDrawer: const Drawer(
        child: MenuDrawer(),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            height: constraints.maxHeight,
            width: constraints.maxWidth,
            child: ListView(
              children: [
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
                Text(
                  noodleItem.instructions,
                  overflow: TextOverflow.clip,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const Text(
                  'How to make',
                  style: TextStyle(
                    fontSize: 32,
                  ),
                ),
                Text(
                  noodleItem.howToMake,
                  overflow: TextOverflow.clip,
                  textAlign: TextAlign.justify,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                )
              ],
            ),
          );
        },
      )
    );
  }
}