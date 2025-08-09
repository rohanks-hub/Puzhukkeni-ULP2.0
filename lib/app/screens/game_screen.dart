import 'package:flutter/material.dart';

class GameScreen extends StatelessWidget {
  final String alarmId;

  const GameScreen({
    super.key,
    required this.alarmId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Integration'),
        automaticallyImplyLeading: false, // Prevent back navigation during alarm
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Game will be integrated here',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            // Temporary button to dismiss alarm - will be replaced by actual game
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Dismiss Alarm (Temporary)'),
            ),
          ],
        ),
      ),
    );
  }
}
