import 'dart:async';
import 'package:flutter/material.dart';

class WormWidget extends StatefulWidget {
  const WormWidget({Key? key}) : super(key: key);

  @override
  _WormWidgetState createState() => _WormWidgetState();
}

class _WormWidgetState extends State<WormWidget> {
  bool _isState1 = true;
  late Timer _timer;

  // TODO: Replace with your actual image paths
  final String wormImage1 = 'assets/images/worm1.png';
  final String wormImage2 = 'assets/images/worm2.png';

  @override
  void initState() {
    super.initState();
    // Switch state every 500ms for animation
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _isState1 = !_isState1;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _isState1 ? wormImage1 : wormImage2,
      width: 50,
      height: 50,
      gaplessPlayback: true, // Prevents flicker when changing images
    );
  }
}