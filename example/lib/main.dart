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

  final apiKey =
      'BSsDAAAAAAAAAAAAABEaIThgEhYUJk9CMBlDT0RBDgeJy_jXGlAqSvX0nv7No3kHUQXK54ui7O7wg2UnuWm5';

  // can be empty
  final userId = '<user-id>';

  final feed = 'test';

  late final initialization = initSdk();

  Future<void> initSdk() async {
    await _inAppStoryPlugin.initWith(apiKey, userId);
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
                    ElevatedButton(
                      onPressed: () async {
                        await IASInAppMessagesHostApi().showById('132');
                      },
                      child: Text("show iam"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final operation =
                            InAppStoryManager.instance.showIAMbyId('132');
                        operation.cancel();
                      },
                      child: Text("show new iam"),
                    ),
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
