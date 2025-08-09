import 'dart:isolate';
import 'dart:ui';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';

// Unique name for the callback
const String miniGameCallbackName = 'miniGameCallback';

// This function will be called when the alarm goes off
void miniGameCallback() async {
  // TODO: Implement logic to launch the mini-game
  debugPrint('Alarm triggered! Launching mini-game...');
  // You can use a background isolate or send a notification to open the mini-game screen
}

class AlarmService {
  static Future<void> initialize() async {
    await AndroidAlarmManager.initialize();
  }

  static Future<void> scheduleAlarm(DateTime dateTime, int id) async {
    final duration = dateTime.difference(DateTime.now());
    await AndroidAlarmManager.oneShot(
      duration,
      id,
      miniGameCallback,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
  }

  static Future<void> cancelAlarm(int id) async {
    await AndroidAlarmManager.cancel(id);
  }
}

