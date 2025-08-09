import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class MiniGameScreen extends StatefulWidget {
  final VoidCallback onWin;
  final VoidCallback onLose;
  final VoidCallback stopAlarm;
  const MiniGameScreen({
    super.key,
    required this.onWin,
    required this.onLose,
    required this.stopAlarm,
  });

  @override
  State<MiniGameScreen> createState() => _MiniGameScreenState();
}

class _MiniGameScreenState extends State<MiniGameScreen> {
  static const int wormCount = 5;
  static const int birdCount = 2;
  static const double wormRadius = 20;
  static const double birdSize = 30;
  static const int gameDuration = 20; // seconds
  final Random _rand = Random();

  late List<Offset> worms;
  late List<Offset> birds;
  late List<bool> wormAlive;
  late Timer _timer;
  late Timer _moveTimer;
  int playerScore = 0;
  int birdScore = 0;
  int timeLeft = gameDuration;
  Size? canvasSize;

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  void _startGame() {
    worms = List.generate(wormCount, (_) => Offset(_rand.nextDouble() * 300 + 50, _rand.nextDouble() * 300 + 50));
    birds = List.generate(birdCount, (_) => Offset(_rand.nextDouble() * 300 + 50, _rand.nextDouble() * 300 + 50));
    wormAlive = List.filled(wormCount, true);
    playerScore = 0;
    birdScore = 0;
    timeLeft = gameDuration;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        timeLeft--;
        if (timeLeft <= 0) {
          _endGame(false);
        }
      });
    });
    _moveTimer = Timer.periodic(const Duration(milliseconds: 50), (_) => _moveEntities());
  }

  void _moveEntities() {
    if (canvasSize == null) return;
    setState(() {
      // Move worms
      for (int i = 0; i < worms.length; i++) {
        if (!wormAlive[i]) continue;
        worms[i] = _moveRandom(worms[i], 2, canvasSize!);
      }
      // Move birds
      for (int i = 0; i < birds.length; i++) {
        birds[i] = _moveRandom(birds[i], 3, canvasSize!);
      }
      // Check collisions
      for (int b = 0; b < birds.length; b++) {
        for (int w = 0; w < worms.length; w++) {
          if (!wormAlive[w]) continue;
          if ((birds[b] - worms[w]).distance < wormRadius + birdSize / 2) {
            wormAlive[w] = false;
            birdScore++;
            if (_allWormsGone()) {
              _endGame(true);
            }
          }
        }
      }
    });
  }

  Offset _moveRandom(Offset pos, double speed, Size size) {
    double dx = (speed * (_rand.nextDouble() * 2 - 1));
    double dy = (speed * (_rand.nextDouble() * 2 - 1));
    double nx = (pos.dx + dx).clamp(0, size.width);
    double ny = (pos.dy + dy).clamp(0, size.height);
    return Offset(nx, ny);
  }

  bool _allWormsGone() => wormAlive.every((alive) => !alive);

  void _endGame(bool win) {
    _timer.cancel();
    _moveTimer.cancel();
    if (win) {
      widget.stopAlarm();
      widget.onWin();
    } else {
      widget.onLose();
      _startGame();
    }
  }

  void _onTapDown(TapDownDetails details) {
    if (canvasSize == null) return;
    final tap = details.localPosition;
    setState(() {
      for (int i = 0; i < worms.length; i++) {
        if (!wormAlive[i]) continue;
        if ((worms[i] - tap).distance < wormRadius) {
          wormAlive[i] = false;
          playerScore++;
          if (_allWormsGone()) {
            _endGame(true);
          }
          break;
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _moveTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mini Game')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          canvasSize = Size(constraints.maxWidth, constraints.maxHeight - 100);
          return Column(
            children: [
              SizedBox(
                height: canvasSize!.height,
                width: canvasSize!.width,
                child: GestureDetector(
                  onTapDown: _onTapDown,
                  child: CustomPaint(
                    painter: _GamePainter(
                      worms: worms,
                      birds: birds,
                      wormAlive: wormAlive,
                      wormRadius: wormRadius,
                      birdSize: birdSize,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Time: $timeLeft'),
                    Text('Player: $playerScore'),
                    Text('Bird: $birdScore'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _GamePainter extends CustomPainter {
  final List<Offset> worms;
  final List<Offset> birds;
  final List<bool> wormAlive;
  final double wormRadius;
  final double birdSize;

  _GamePainter({
    required this.worms,
    required this.birds,
    required this.wormAlive,
    required this.wormRadius,
    required this.birdSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final wormPaint = Paint()..color = Colors.green;
    final birdPaint = Paint()..color = Colors.blue;
    for (int i = 0; i < worms.length; i++) {
      if (wormAlive[i]) {
        canvas.drawCircle(worms[i], wormRadius, wormPaint);
      }
    }
    for (final b in birds) {
      canvas.drawRect(Rect.fromCenter(center: b, width: birdSize, height: birdSize), birdPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

