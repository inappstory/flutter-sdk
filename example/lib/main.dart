import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final _inAppStoryPlugin = InAppStoryPlugin();

  final apiKey = 'test-key';

  // can be empty
  final userId = '<user-id>';

  final feed = 'flutter';

  late final initialization = initSdk();

  Future<void> initSdk() async {
    await _inAppStoryPlugin.initWith(apiKey, userId,
        anonymous: false, isLoggingEnabled: true);
    //await AppearanceManager.instance.setHasFavorites(true);

    InAppStoryManager.instance.logger = IASLogger.create(
      onDebugLog: (tag, message) {
        //print('$tag: $message');
      },
      onErrorLog: (tag, message) {
        //print('$tag: $message');
      },
      printToConsole: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('InAppStory Example'),
        ),
        body: FutureBuilder(
          future: initialization,
          builder: (context, initializationSnapshot) {
            if (initializationSnapshot.connectionState ==
                ConnectionState.done) {
              if (initializationSnapshot.hasError) {
                return const Text('SDK was not initialized');
              } else {
                return Column(
                  children: [
                    FeedStoriesWidget(
                      feed: feed,
                    ),
                    BannerPlace(placeId: 'mini_banner', height: 120),
                  ],
                );
              }
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
