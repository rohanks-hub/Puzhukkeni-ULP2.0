import 'dart:async';
import 'package:flutter/material.dart';

enum BirdState { moving, eating }

class BirdWidget extends StatefulWidget {
  const BirdWidget({Key? key}) : super(key: key);

  @override
  // The State class is made public so we can call the `eat` method from the parent.
  BirdWidgetState createState() => BirdWidgetState();
}

class BirdWidgetState extends State<BirdWidget> {
  BirdState _birdState = BirdState.moving;

  // TODO: Replace with your actual image paths
  final String movingBirdImage = 'assets/images/bird_moving.png';
  final String eatingBirdImage = 'assets/images/bird_eating.png';

  // This method can be called from outside using a GlobalKey
  void eat() {
    // Only trigger "eating" state if currently moving
    if (mounted && _birdState == BirdState.moving) {
      setState(() {
        _birdState = BirdState.eating;
      });

      // After 1 second, go back to moving state
      Timer(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _birdState = BirdState.moving;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // return Image.asset(
    //   _birdState == BirdState.moving ? movingBirdImage : eatingBirdImage,
    //   width: 80,
    //   height: 80,
    //   gaplessPlayback: true, // Prevents flicker when changing images
    // );
    return Container(
      width: 80,
      height: 80,
      color: _birdState == BirdState.moving ? Colors.blue : Colors.red,
      child: Center(
        child: Text(
          _birdState == BirdState.moving ? 'BIRD' : 'EATING',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}