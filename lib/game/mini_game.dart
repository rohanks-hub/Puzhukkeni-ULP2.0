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
  static const int wormCount = 12; // Increased number of worms
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
    // Use the full screen size for spawning worms and birds
    final width = canvasSize?.width ?? 400;
    final height = canvasSize?.height ?? 400;
    worms = List.generate(wormCount, (_) => Offset(_rand.nextDouble() * (width - 40) + 20, _rand.nextDouble() * (height - 40) + 20));
    birds = List.generate(birdCount, (_) => Offset(_rand.nextDouble() * (width - 40) + 20, _rand.nextDouble() * (height - 40) + 20));
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
      // Move birds towards nearest alive worm
      for (int i = 0; i < birds.length; i++) {
        Offset? target;
        double minDist = double.infinity;
        for (int w = 0; w < worms.length; w++) {
          if (!wormAlive[w]) continue;
          double dist = (worms[w] - birds[i]).distance;
          if (dist < minDist) {
            minDist = dist;
            target = worms[w];
          }
        }
        if (target != null) {
          birds[i] = _moveTowards(birds[i], target, 7, canvasSize!);
        }
      }
      // Check collisions
      for (int b = 0; b < birds.length; b++) {
        for (int w = 0; w < worms.length; w++) {
          if (!wormAlive[w]) continue;
          if ((birds[b] - worms[w]).distance < wormRadius + birdSize / 2) {
            wormAlive[w] = false;
            birdScore++;
            // Only end game if all worms are gone
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

  Offset _moveTowards(Offset from, Offset to, double speed, Size size) {
    final dir = (to - from);
    final dist = dir.distance;
    if (dist == 0) return from;
    final step = dir / dist * speed;
    double nx = (from.dx + step.dx).clamp(0, size.width);
    double ny = (from.dy + step.dy).clamp(0, size.height);
    return Offset(nx, ny);
  }

  bool _allWormsGone() => wormAlive.every((alive) => !alive);

  void _endGame(bool win) {
    _timer.cancel();
    _moveTimer.cancel();
    // Win only if playerScore > birdScore
    if (playerScore > birdScore) {
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
          // Only end game if all worms are gone
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
      appBar: null, // Remove AppBar for true fullscreen
      body: LayoutBuilder(
        builder: (context, constraints) {
          canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
          if (worms.isEmpty || birds.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) => setState(_startGame));
          }
          return GestureDetector(
            onTapDown: _onTapDown,
            child: Stack(
              children: [
                CustomPaint(
                  painter: _GamePainter(
                    worms: worms,
                    birds: birds,
                    wormAlive: wormAlive,
                    wormRadius: wormRadius,
                    birdSize: birdSize,
                  ),
                  size: Size.infinite,
                ),
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Time: $timeLeft'),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Player: $playerScore'),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Bird: $birdScore'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
