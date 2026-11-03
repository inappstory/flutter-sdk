import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:inappstory_plugin/inappstory_plugin.dart';

class GamesWidget extends StatefulWidget {
  const GamesWidget({super.key});

  @override
  State<GamesWidget> createState() => _GamesWidgetState();
}

class _GamesWidgetState extends State<GamesWidget> with IASGameReaderCallback {
  final _inputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Games")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                label: Text('Input game id string'),
              ),
              controller: _inputController,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: startIASGame,
              child: const Text('Start game'),
            ),
          ],
        ),
      ),
    );
  }

  void startIASGame() async {
    InAppStoryManager.instance.openGame(_inputController.text);
  }

  @override
  Future<void> startGame(ContentData? gameData) async {
    log('startGame');
  }

  @override
  Future<void> closeGame(ContentData? gameData) async {
    log('closeGame');
  }

  @override
  Future<void> eventGame(
    ContentData? gameData,
    String? id,
    String? eventName,
    Map<String, Object?>? payload,
  ) async {
    log('eventGame');
  }

  @override
  Future<void> finishGame(ContentData? gameData, Map<String, Object?>? result) async {
    log('finishGame');
  }

  @override
  Future<void> gameError(ContentData? gameData, String? message) async {
    log('gameError');
  }
}
