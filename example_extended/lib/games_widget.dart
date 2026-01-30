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
    IASGamesHostApi().openGame(_inputController.text);
  }

  @override
  void startGame(ContentDataDto? gameData) {
    log('startGame');
  }

  @override
  void closeGame(ContentDataDto? gameData) {
    log('closeGame');
  }

  @override
  void eventGame(
    ContentDataDto? gameData,
    String? id,
    String? eventName,
    Map<String?, Object?>? payload,
  ) {
    log('eventGame');
  }

  @override
  void finishGame(ContentDataDto? gameData, Map<String?, Object?>? result) {
    log('finishGame');
  }

  @override
  void gameError(ContentDataDto? gameData, String? message) {
    log('gameError');
  }
}
