import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../widgets/bird_widget.dart';
import '../widgets/worm_widget.dart';

// Data models for our animated objects
class BirdModel {
  final GlobalKey<BirdWidgetState> key = GlobalKey();
  Offset position;
  Offset velocity;

  BirdModel({required this.position, required this.velocity});
}

class WormModel {
  final String id = const Uuid().v4();
  Offset position;
  Offset velocity;

  WormModel({required this.position, required this.velocity});
}

class AlarmAnimationScreen extends StatefulWidget {
  const AlarmAnimationScreen({Key? key}) : super(key: key);

  @override
  _AlarmAnimationScreenState createState() => _AlarmAnimationScreenState();
}

class _AlarmAnimationScreenState extends State<AlarmAnimationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<WormModel> _worms = [];
  final Random _random = Random();
  Size _screenSize = Size.zero;

  // Define the size of our characters
  static const double wormSize = 50.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      // Duration is not critical here as we are using a repeating controller
      duration: const Duration(seconds: 1),
      vsync: this,
    )..addListener(_update);

    // We need the screen size to initialize positions. We get it safely here.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _screenSize = MediaQuery.of(context).size;
        _initializeWorms(5); // Let's start with 5 worms
        _controller.repeat(); // Start the animation loop
      }
    });
  }

  void _initializeWorms(int count) {
    for (int i = 0; i < count; i++) {
      _worms.add(WormModel(
        position: Offset(
          _random.nextDouble() * (_screenSize.width - wormSize),
          _random.nextDouble() * (_screenSize.height - wormSize),
        ),
        // Set a random velocity
        velocity: Offset(
          (_random.nextDouble() * 4) - 2, // -2.0 to 2.0
          (_random.nextDouble() * 4) - 2, // -2.0 to 2.0
        ),
      ));
    }
    setState(() {});
  }

  void _update() {
    // This method is called for every frame
    if (!mounted) return;

    setState(() {
      for (final worm in _worms) {
        // Update position based on velocity
        worm.position += worm.velocity;

        // Check for collision with screen edges and reverse velocity (bounce)
        if (worm.position.dx <= 0 ||
            worm.position.dx >= _screenSize.width - wormSize) {
          worm.velocity = Offset(-worm.velocity.dx, worm.velocity.dy);
        }
        if (worm.position.dy <= 0 ||
            worm.position.dy >= _screenSize.height - wormSize) {
          worm.velocity = Offset(worm.velocity.dx, -worm.velocity.dy);
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.shade300, // A nice "dirt" color
      body: Stack(
        children: _worms
            .map((worm) => Positioned(
                  left: worm.position.dx,
                  top: worm.position.dy,
                  child: const WormWidget(),
                ))
            .toList(),
      ),
    );
  }
}
