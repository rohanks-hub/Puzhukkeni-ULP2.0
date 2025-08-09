import 'package:flutter/material.dart';

class AppColors {
  static const primary = Colors.blue;
  static const secondary = Colors.orange;
  static const background = Colors.white;
  static const cardBackground = Colors.white;
}

class AppConfig {
  static const String appName = 'Puzukkeni';
  static const Duration alarmSnoozeLength = Duration(minutes: 5);
  static const Duration gameTimeLimit = Duration(minutes: 1);
}

class AssetPaths {
  static const String birdImage = 'assets/images/bird.png';
  static const String wormImage = 'assets/images/worm.png';
  static const String alarmSound = 'assets/sounds/alarm.mp3';
  static const String clickSound = 'assets/sounds/click.mp3';
}
