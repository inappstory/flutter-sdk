import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';

class InAppMessages extends StatefulWidget {
  const InAppMessages({super.key});

  @override
  State<InAppMessages> createState() => _InAppMessagesState();
}

class _InAppMessagesState extends State<InAppMessages>
    with IASInAppMessageCallback {
  final _inputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("In-App-Messaging"),
      ),
      body: SafeArea(
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            spacing: 12,
            children: [
              TextField(
                decoration: const InputDecoration(
                  label: Text('Input InAppMessage id or event'),
                ),
                controller: _inputController,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () => IASInAppMessagesHostApi()
                        .showById(_inputController.text, onlyPreloaded: false),
                    child: const Text("Show by id"),
                  ),
                  ElevatedButton(
                    onPressed: () => IASInAppMessagesHostApi()
                        .showByEvent(_inputController.text),
                    child: const Text("Show by event"),
                  ),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("InAppMessage preloading"),
                  ElevatedButton(
                    onPressed: () async {
                      final result =
                          await IASInAppMessagesHostApi().preloadMessages();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                result ? "Success" : "Error loading messages"),
                          ),
                        );
                      }
                    },
                    child: const Text("preload"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onShowInAppMessage(InAppMessageDataDto? inAppMessageData) {
    print("IAM: onShowInAppMessage: ${inAppMessageData?.id}");
  }

  @override
  void onCloseInAppMessage(InAppMessageDataDto? inAppMessageData) {
    print("IAM: onCloseInAppMessage: ${inAppMessageData?.id}");
  }

  @override
  void onInAppMessageWidgetEvent(InAppMessageDataDto? inAppMessageData,
      String? name, Map<String?, Object?>? data) {
    print("IAM: onInAppMessageWidgetEvent: ${inAppMessageData?.id}");
  }
}
