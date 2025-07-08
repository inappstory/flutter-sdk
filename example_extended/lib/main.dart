import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';

import 'games_widget.dart';
import 'in_app_messages.dart';
import 'keys.dart';
import 'localization_delegates.dart';
import 'simple_feed_example.dart';

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
      navigatorKey.currentState ??
      (throw Exception('navigatorKey is not set to MaterialApp'));

  final _inAppStoryPlugin = InAppStoryPlugin();
  final appearanceManager = AppearanceManager.instance;

  late final initialization = initSdk();

  Future<void> initSdk() async {
    await _inAppStoryPlugin.initWith(Keys.apiKey, Keys.userId);
    await appearanceManager.setHasLike(true);
    await appearanceManager.setHasFavorites(true);
    await appearanceManager.setHasShare(true);
  }

  void onSimpleExampleTap() {
    navigatorState.push(
      MaterialPageRoute(builder: (_) => const SimpleFeedExampleWidget()),
    );
  }

  void onGamesTap() {
    navigatorState.push(MaterialPageRoute(builder: (_) => const GamesWidget()));
  }

  void onInAppMessagesTap() {
    navigatorState.push(
      MaterialPageRoute(builder: (_) => const InAppMessages()),
    );
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
        AnyLocaleLocalizationsDelegate<MaterialLocalizations>(
          DefaultMaterialLocalizations.delegate,
        ),
        AnyLocaleLocalizationsDelegate<CupertinoLocalizations>(
          DefaultCupertinoLocalizations.delegate,
        ),
        WidgetsLocalizationsDelegate(textDirection),
      ],
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Center(
          child: FutureBuilder(
            future: initialization,
            builder: (context, initializationSnapshot) {
              if (initializationSnapshot.connectionState ==
                  ConnectionState.done) {
                if (initializationSnapshot.hasError) {
                  return const Text('SDK was not initialized');
                } else {
                  return Column(
                    children: [
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: toggleRtl,
                        child: Text('toggleRtl ${textDirection.name}'),
                      ),
                      ElevatedButton(
                        onPressed: onSimpleExampleTap,
                        child: const Text('Simple Feed Example'),
                      ),
                      ElevatedButton(
                        onPressed: onGamesTap,
                        child: const Text('Games'),
                      ),
                      ElevatedButton(
                        onPressed: onInAppMessagesTap,
                        child: const Text('InAppMessages'),
                      ),
                    ],
                  );
                }
              }

              return const CircularProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
