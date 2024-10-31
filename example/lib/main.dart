import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import 'package:inappstory_plugin_example/simple_feed_exmaple.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get navigatorState =>
      navigatorKey.currentState ?? (throw Exception('navigatorKey is not set to MaterialApp'));

  final _inappstoryPlugin = InappstoryPlugin();

  final defaultFeedStoriesStream = StoriesStream.feed('default');

  @override
  void initState() {
    super.initState();
    _inappstoryPlugin.initWith('test-key', 'testUserId', true, false);
  }

  void onSimpleExampleTap() {
    navigatorState.push(MaterialPageRoute(builder: (_) => const SimpleFeedExampleWidget()));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              const SizedBox(height: 24),
              ElevatedButton(onPressed: onSimpleExampleTap, child: const Text('SimpleExample')),
            ],
          ),
        ),
      ),
    );
  }
}
