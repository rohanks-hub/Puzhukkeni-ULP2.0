import 'dart:async';
import 'package:flutter/material.dart';
import '../models/alarm.dart';
import '../screens/game_screen.dart';

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;
  AlarmService._internal();

  final Map<String, Timer> _activeAlarms = {};

  void scheduleAlarm(BuildContext context, Alarm alarm) {
    // Don't schedule if alarm is inactive
    if (!alarm.isActive) {
      cancelAlarm(alarm.id);
      return;
    }

    // Cancel existing timer if any
    cancelAlarm(alarm.id);

    final now = DateTime.now();
    var scheduledTime = alarm.time;

    // If the alarm time is in the past, schedule it for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = DateTime(
        now.year,
        now.month,
        now.day + 1,
        alarm.time.hour,
        alarm.time.minute,
      );
    }

    final duration = scheduledTime.difference(now);

    _activeAlarms[alarm.id] = Timer(duration, () {
      _triggerAlarm(context, alarm);
    });
  }

  void cancelAlarm(String alarmId) {
    _activeAlarms[alarmId]?.cancel();
    _activeAlarms.remove(alarmId);
  }

  void _triggerAlarm(BuildContext context, Alarm alarm) {
    // TODO: Start playing alarm sound in a loop here

    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => GameScreen(alarmId: alarm.id),
        ),
      ).then((_) {
        // Reschedule the alarm for the next day after it's dismissed
        if (alarm.isActive) {
          scheduleAlarm(context, alarm);
        }
      });
    }
  }

  void dispose() {
    for (var timer in _activeAlarms.values) {
      timer.cancel();
    }
    _activeAlarms.clear();
  }
}
