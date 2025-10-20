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

class _MyAppState extends State<MyApp>
    with WidgetsBindingObserver, IASBannerPlaceCallback {
  final _inAppStoryPlugin = InAppStoryPlugin();

  final apiKey = 'test-key';

  // can be empty
  final userId = '<user-id>';

  final feed = 'flutter';

  late final initialization = initSdk();

  Future<void> initSdk() async {
    await _inAppStoryPlugin.initWith(apiKey, userId);
  }

  double _size = 150;

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
                    Container(
                      decoration: BoxDecoration(
                        // gradient: LinearGradient(
                        //   colors: [],
                        //   begin: Alignment.bottomCenter,
                        //   end: Alignment.topCenter,
                        // ),
                      ),
                      child: FeedStoriesWidget(
                        feed: feed,
                      ),
                    ),
                    AnimatedSize(
                      duration: Duration(milliseconds: 300),
                      child: BannerPlace(
                        placeId: "app-head",
                        height: _size,
                        placeDecoration: BannerPlaceDecoration(
                          bannerOffset: 20,
                          bannersGap: 10,
                          cornerRadius: 12,
                          loop: true,
                        ),
                        bannerDecoration: BannerDecoration(
                          //color: Colors.amber,
                          gradientStops: [0, 0.5, 1.0],
                          gradientColors: [
                            Colors.black,
                            Colors.white,
                            Colors.amber,
                          ],
                          image: "assets/icons/bell.png",
                          gradientType: GradientType.linear,
                        ),
                      ),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          BannerPlaceManager.instance.load("app-head");
                          // Future.delayed(const Duration(seconds: 2),
                          //     () => BannerPlaceManager.instance.showNext());
                        },
                        child: const Text("load"))
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

  @override
  void onBannerScroll(int index) {}

  @override
  void onBannerPlaceLoaded(int size, int widgetHeight) {
    setState(() {
      _size = widgetHeight.toDouble();
    });
  }
}
