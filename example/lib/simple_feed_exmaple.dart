import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';

class SimpleFeedExampleWidget extends StatefulWidget {
  const SimpleFeedExampleWidget({super.key});

  @override
  State<SimpleFeedExampleWidget> createState() => _SimpleFeedExmapleState();
}

class _SimpleFeedExmapleState extends State<SimpleFeedExampleWidget> {
  final defaultStoriesFuture = InappstoryPlugin().getStories2('default');

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SimpleFeedExample'),
        ),
        body: SizedBox(
          height: 100,
          child: FutureBuilder(
            future: defaultStoriesFuture,
            builder: (_, storiesSnapshot) {
              if (storiesSnapshot.hasData) {
                return ListView.separated(
                  itemCount: storiesSnapshot.requireData.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, index) {
                    return DefaultStoryWidget(storiesSnapshot.requireData.elementAt(index));
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(width: 16);
                  },
                );
              }

              if (storiesSnapshot.hasError) {
                return Text(
                  '${storiesSnapshot.error}',
                  style: const TextStyle(color: Colors.red),
                );
              }
              return const LinearProgressIndicator();
            },
          ),
        ),
      ),
    );
  }
}
