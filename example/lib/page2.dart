import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';

class Page2 extends StatefulWidget {
  const Page2({super.key});

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> with IASBannerPlaceCallback {
  double _size = 150;

  final String placeId = "app-head";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        print(timeStamp.toString());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          const Text("Example"),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: BannerPlace(
              placeId: placeId,
              height: _size,
              autoLoad: false,
              bannerPlaceLoaderBuilder: (context) {
                return const BannerPlacePlaceholder();
              },
              placeDecoration: BannerPlaceDecoration(
                bannerOffset: 20,
                bannersGap: 10,
                cornerRadius: 20,
                loop: true,
              ),
              bannerDecoration: BannerDecoration(
                color: Colors.amber,
                image: "assets/icons/bell.png",
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void onBannerPlaceLoaded(int size, int widgetHeight) {
    print("Bannerplace: ${size.toString()} - ${widgetHeight.toString()}");
    setState(() {
      _size = widgetHeight.toDouble();
    });
  }
}
