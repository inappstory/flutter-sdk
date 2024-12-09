import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';

class AppearanceManagerWidget extends StatefulWidget {
  const AppearanceManagerWidget({super.key});

  @override
  State<AppearanceManagerWidget> createState() => _AppearanceManagerWidgetState();
}

class _AppearanceManagerWidgetState extends State<AppearanceManagerWidget> {
  Position position = Position.bottomRight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance Manager'),
      ),
      body: Column(
        children: [
          const Text('Story Reader close button position'),
          AspectRatio(
            aspectRatio: 1,
            child: GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              children: [
                for (final position in Position.values)
                  TextButton(
                    onPressed: () {
                      AppearanceManagerHostApi().setClosePosition(position);
                    },
                    child: Text(position.name),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
