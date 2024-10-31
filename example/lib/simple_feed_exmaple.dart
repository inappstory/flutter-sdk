import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';

class SimpleFeedExampleWidget extends StatefulWidget {
  const SimpleFeedExampleWidget({super.key});

  @override
  State<SimpleFeedExampleWidget> createState() => _SimpleFeedExampleState();
}

class _SimpleFeedExampleState extends State<SimpleFeedExampleWidget> implements CallToActionCallbackFlutterApi {
  final defaultStoriesFuture = InappstoryPlugin().getStories2('default');

  @override
  void initState() {
    super.initState();
    CallToActionCallbackFlutterApi.setUp(this);
  }

  @override
  void dispose() {
    CallToActionCallbackFlutterApi.setUp(null);
    super.dispose();
  }

  final callsToAction = <String>[];

  @override
  void callToAction(SlideDataDto? slideData, String? url, ClickActionDto? clickAction) {
    setState(() {
      final content = 'slideData:$slideData url:$url clickAction:${clickAction?.name}';

      callsToAction.add(content);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SimpleFeedExample'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
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
          const Divider(),
          const Text('Calls To Actions'),
          Expanded(
            child: ListView.builder(
              itemCount: callsToAction.length,
              itemBuilder: (_, index) => Text(callsToAction[index]),
            ),
          ),
        ],
      ),
    );
  }
}
