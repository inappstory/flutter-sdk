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

  final _feedStoriesController = FeedStoriesController();

  final apiKey = 'test-key';

  // can be empty
  final userId = '<user-id>';

  final feed = 'flutter';

  late final initialization = initSdk();

  Future<void> initSdk() async {
    await _inAppStoryPlugin.initWith(apiKey, userId);
  }

  Future<void> _onRefresh() async {
    InAppStoryManager.instance.showIAMById('1411');
    await _feedStoriesController.fetchFeedStories();
    await BannerPlaceManager.instance.reload('app-head');
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
                return RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        FeedStoriesWidget(
                          feed: feed,
                          controller: _feedStoriesController,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            InAppStoryManager.instance.showIAMById('1411');
                            // showModalBottomSheet(
                            //     context: context,
                            //     builder: (_) {
                            //       return const SizedBox(
                            //         height: 200,
                            //         width: double.infinity,
                            //         child: Center(child: Text('ff')),
                            //       );
                            //     });
                          },
                          child: const Text('ggg'),
                        ),
                        //const SizedBox(height: 200),
                        const BannerPlace(placeId: 'app-head', height: 150),
                      ],
                    ),
                  ),
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
