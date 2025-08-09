import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../models/alarm.dart';
import '../screens/game_screen.dart';

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;

  final Map<String, Timer> _activeAlarms = {};
  bool _isInitialized = false;

  AlarmService._internal();

  Future<void> init() async {
    if (_isInitialized) return;

    if (html.Notification.supported) {
      final permission = await html.Notification.requestPermission();
      _isInitialized = permission == 'granted';
    }
  }

  Future<void> scheduleAlarm(BuildContext context, Alarm alarm) async {
    if (!_isInitialized) await init();

    if (!alarm.isActive) {
      cancelAlarm(alarm.id);
      return;
    }

    final now = DateTime.now();
    final alarmTime = alarm.time;
    var scheduledTime = alarmTime;

    // If alarm time is in the past, schedule for next day
    if (alarmTime.isBefore(now)) {
      scheduledTime = DateTime(
        now.year,
        now.month,
        now.day + 1,
        alarmTime.hour,
        alarmTime.minute,
      );
    }

    final delay = scheduledTime.difference(now);

    // Cancel any existing timer for this alarm
    cancelAlarm(alarm.id);

    // Schedule new timer
    _activeAlarms[alarm.id] = Timer(delay, () {
      _showNotification(context, alarm);
    });
  }

  void _showNotification(BuildContext context, Alarm alarm) {
    if (html.Notification.supported) {
      html.Notification(
        'Alarm: ${alarm.label}',
        body: 'Time to wake up!',
      );

      // Navigate to game screen when notification is shown
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GameScreen(alarmId: alarm.id),
          ),
        );
      });
    }
  }

  void cancelAlarm(String id) {
    _activeAlarms[id]?.cancel();
    _activeAlarms.remove(id);
  }

  void dispose() {
    for (var timer in _activeAlarms.values) {
      timer.cancel();
    }
    _activeAlarms.clear();
  }
}
