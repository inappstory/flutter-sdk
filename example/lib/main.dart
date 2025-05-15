import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';
import 'package:inappstory_plugin_example/games_widget.dart';
import 'package:inappstory_plugin_example/in_app_messages.dart';

import 'appearance_manager_widget.dart';
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

class _MyAppState extends State<MyApp>
    with WidgetsBindingObserver
    implements OnboardingLoadCallbackFlutterApi {
  final navigatorKey = GlobalKey<NavigatorState>();

  NavigatorState get navigatorState =>
      navigatorKey.currentState ??
      (throw Exception('navigatorKey is not set to MaterialApp'));

  final _inAppStoryPlugin = InAppStoryPlugin();
  final appearanceManager = AppearanceManagerHostApi();

  late final initialization = initSdk();

  @override
  void initState() {
    super.initState();
    OnboardingLoadCallbackFlutterApi.setUp(this);
  }

  @override
  void dispose() {
    OnboardingLoadCallbackFlutterApi.setUp(null);
    super.dispose();
  }

  Future<void> initSdk() async {
    await _inAppStoryPlugin.initWith('<your key>', '<some user id>', false);
    await appearanceManager.setHasLike(true);
    await appearanceManager.setHasFavorites(true);
    await appearanceManager.setHasShare(true);
  }

  void onSimpleExampleTap() {
    navigatorState.push(
        MaterialPageRoute(builder: (_) => const SimpleFeedExampleWidget()));
  }

  void onAppearanceManagerTap() {
    navigatorState.push(
        MaterialPageRoute(builder: (_) => const AppearanceManagerWidget()));
  }

  void onOnboardingsTap() {
    IASOnboardingsHostApi().show(limit: 10);
  }

  void onGamesTap() {
    navigatorState.push(MaterialPageRoute(builder: (_) => const GamesWidget()));
  }

  void onInAppMessagesTap() {
    navigatorState
        .push(MaterialPageRoute(builder: (_) => const InAppMessages()));
  }

  @override
  void onboardingLoadSuccess(int count, String feed) {
    print('$runtimeType.onboardingLoad($count, $feed)');
  }

  @override
  void onboardingLoadError(String feed, String? reason) {
    print('$runtimeType.onboardingLoad($feed, $reason)');
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
            DefaultMaterialLocalizations.delegate),
        AnyLocaleLocalizationsDelegate<CupertinoLocalizations>(
            DefaultCupertinoLocalizations.delegate),
        WidgetsLocalizationsDelegate(textDirection),
      ],
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
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
                          child: Text('toggleRtl ${textDirection.name}')),
                      ElevatedButton(
                          onPressed: onSimpleExampleTap,
                          child: const Text('Simple Feed Example')),
                      ElevatedButton(
                          onPressed: onAppearanceManagerTap,
                          child: const Text('Appearance Manager')),
                      ElevatedButton(
                          onPressed: onOnboardingsTap,
                          child: const Text('Onboardings (shown only if any)')),
                      ElevatedButton(
                          onPressed: onGamesTap, child: const Text('Games')),
                      ElevatedButton(
                          onPressed: onInAppMessagesTap,
                          child: const Text('InAppMessages')),
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
