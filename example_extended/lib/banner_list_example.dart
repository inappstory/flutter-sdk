import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';

import 'keys.dart';

class BannerListExample extends StatelessWidget {
  const BannerListExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Banner List')),
      body: LayoutBuilder(
        builder:
            (context, constraints) => BannerList(
              placeId: Keys.bannerPlaceId,
              height: constraints.maxHeight,
            ),
      ),
    );
  }
}
