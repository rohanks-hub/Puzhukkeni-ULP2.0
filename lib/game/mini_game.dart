import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class MiniGameScreen extends StatefulWidget {
  final VoidCallback onWin;
  final VoidCallback onLose;

  const MiniGameScreen({Key? key, required this.onWin, required this.onLose}) : super(key: key);

  @override
  State<MiniGameScreen> createState() => _MiniGameScreenState();
}

class _MiniGameState {
  Offset position;
  bool alive;
  _MiniGameState(this.position) : alive = true;
}

class _MiniGameScreenState extends State<MiniGameScreen> with SingleTickerProviderStateMixin {
  static const int wormCount = 5;
  static const int birdCount = 2;
  static const double wormRadius = 20;
  static const double birdSize = 30;
  static const int gameDuration = 20; // seconds

  late List<_MiniGameState> worms;
  late List<_MiniGameState> birds;
  int playerScore = 0;
  int birdScore = 0;
  late Timer timer;
  int timeLeft = gameDuration;
  late Ticker _ticker;
  final Random _rand = Random();
  Size? _canvasSize;

  @override
  void initState() {
    super.initState();
    _initGame();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        timeLeft--;
        if (timeLeft <= 0) _endGame(false);
      });
    });
    _ticker = createTicker(_onTick)..start();
  }

  void _initGame() {
    worms = List.generate(wormCount, (_) => _MiniGameState(_randomPos()));
    birds = List.generate(birdCount, (_) => _MiniGameState(_randomPos()));
    playerScore = 0;
    birdScore = 0;
    timeLeft = gameDuration;
  }

  Offset _randomPos() {
    if (_canvasSize == null) return Offset.zero;
    return Offset(
      _rand.nextDouble() * (_canvasSize!.width - wormRadius * 2) + wormRadius,
      _rand.nextDouble() * (_canvasSize!.height - wormRadius * 2) + wormRadius,
    );
  }

  void _onTick(Duration elapsed) {
    setState(() {
      // Move worms and birds randomly
      for (var worm in worms) {
        if (!worm.alive) continue;
        worm.position += Offset(_rand.nextDouble() * 2 - 1, _rand.nextDouble() * 2 - 1) * 1.5;
      }
      for (var bird in birds) {
        if (!bird.alive) continue;
        bird.position += Offset(_rand.nextDouble() * 2 - 1, _rand.nextDouble() * 2 - 1) * 2.0;
      }
      // Bird eats worm
      for (var bird in birds) {
        if (!bird.alive) continue;
        for (var worm in worms) {
          if (!worm.alive) continue;
          if ((bird.position - worm.position).distance < wormRadius + birdSize / 2) {
            worm.alive = false;
            birdScore++;
          }
        }
      }
      // Win/lose check
      if (worms.where((w) => w.alive).isEmpty) {
        _endGame(true);
      }
    });
  }

  void _endGame(bool win) {
    timer.cancel();
    _ticker.stop();
    if (win) {
      widget.onWin();
    } else {
      widget.onLose();
      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() {
          _initGame();
          _ticker.start();
          timer = Timer.periodic(const Duration(seconds: 1), (t) {
            setState(() {
              timeLeft--;
              if (timeLeft <= 0) _endGame(false);
            });
          });
        });
      });
    }
  }

  @override
  void dispose() {
    timer.cancel();
    _ticker.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    final tap = details.localPosition;
    setState(() {
      for (var worm in worms) {
        if (!worm.alive) continue;
        if ((worm.position - tap).distance < wormRadius) {
          worm.alive = false;
          playerScore++;
        }
      }
      if (worms.where((w) => w.alive).isEmpty) {
        _endGame(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          onTapDown: _onTapDown,
          child: CustomPaint(
            size: Size.infinite,
            painter: _MiniGamePainter(
              worms: worms,
              birds: birds,
              wormRadius: wormRadius,
              birdSize: birdSize,
              playerScore: playerScore,
              birdScore: birdScore,
              timeLeft: timeLeft,
            ),
          ),
        );
      },
    );
  }
}

class _MiniGamePainter extends CustomPainter {
  final List<_MiniGameState> worms;
  final List<_MiniGameState> birds;
  final double wormRadius;
  final double birdSize;
  final int playerScore;
  final int birdScore;
  final int timeLeft;

  _MiniGamePainter({
    required this.worms,
    required this.birds,
    required this.wormRadius,
    required this.birdSize,
    required this.playerScore,
    required this.birdScore,
    required this.timeLeft,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    // Draw worms
    for (var worm in worms) {
      if (!worm.alive) continue;
      paint.color = Colors.green;
      canvas.drawCircle(worm.position, wormRadius, paint);
    }
    // Draw birds
    for (var bird in birds) {
      if (!bird.alive) continue;
      paint.color = Colors.red;
      final rect = Rect.fromCenter(center: bird.position, width: birdSize, height: birdSize);
      canvas.drawRect(rect, paint);
    }
    // Draw scores and timer
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'You: $playerScore  Birds: $birdScore  Time: $timeLeft',
        style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, const Offset(10, 10));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

