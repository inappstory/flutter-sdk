import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import 'package:inappstory_plugin_example/simple_feed_exmaple.dart';

import 'localization_delegates.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get navigatorState =>
      navigatorKey.currentState ?? (throw Exception('navigatorKey is not set to MaterialApp'));

  final _inappstoryPlugin = InappstoryPlugin();

  final defaultFeedStoriesStream = StoriesStream.feed('default');

  @override
  void initState() {
    super.initState();
    _inappstoryPlugin.initWith('test-key', 'testUserId', false);
  }

  void onSimpleExampleTap() {
    navigatorState.push(MaterialPageRoute(builder: (_) => const SimpleFeedExampleWidget()));
  }

  TextDirection textDirection = TextDirection.ltr;

  void toggleRtl() {
    setState(() {
      textDirection = switch (textDirection) {
        TextDirection.rtl => TextDirection.ltr,
        TextDirection.ltr => TextDirection.rtl,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      localizationsDelegates: [
        AnyLocaleLocalizationsDelegate<MaterialLocalizations>(DefaultMaterialLocalizations.delegate),
        AnyLocaleLocalizationsDelegate<CupertinoLocalizations>(DefaultCupertinoLocalizations.delegate),
        WidgetsLocalizationsDelegate(textDirection),
      ],
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              const SizedBox(height: 24),
              ElevatedButton(onPressed: toggleRtl, child: Text('toggleRtl ${textDirection.name}')),
              ElevatedButton(onPressed: onSimpleExampleTap, child: const Text('SimpleExample')),
            ],
          ),
        ),
      ),
    );
  }
}
