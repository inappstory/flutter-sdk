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
            children: [
              ElevatedButton(
                onPressed: () async {
                  final result =
                      await IASInAppMessagesHostApi().preloadMessages();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text(result ? "Success" : "Error loading messages"),
                      ),
                    );
                  }
                },
                child: const Text("preload"),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        label: Text('Input InAppMessage id'),
                      ),
                      controller: _inputController,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      IASInAppMessagesHostApi().show(_inputController.text);
                    },
                    child: const Text("Show"),
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
