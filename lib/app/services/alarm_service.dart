import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import '../models/alarm.dart';
import '../../game/mini_game.dart';

class AlarmService {
  static final AlarmService _instance = AlarmService._internal();
  factory AlarmService() => _instance;

  final Map<String, Timer> _activeAlarms = {};
  bool _isInitialized = false;
  html.AudioElement? _audio;

  AlarmService._internal();

  Future<void> init() async {
    if (_isInitialized) return;

    if (html.Notification.supported) {
      final permission = await html.Notification.requestPermission();
      _isInitialized = permission == 'granted';
    }
  }

  void _playAlarmSound() {
    _audio?.pause();
    _audio = html.AudioElement();
    _audio!.src = 'https://actions.google.com/sounds/v1/alarms/alarm_clock.ogg';
    _audio!.loop = true;
    _audio!.play();
  }

  void _stopAlarmSound() {
    _audio?.pause();
    _audio = null;
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

    _activeAlarms[alarm.id] = Timer(delay, () async {
      _playAlarmSound();
      if (_isInitialized) {
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => WillPopScope(
            onWillPop: () async => false,
            child: MiniGameScreen(
              onWin: () {
                _stopAlarmSound();
                Navigator.of(ctx).pop();
              },
              onLose: () {},
              stopAlarm: _stopAlarmSound,
            ),
          ),
        );
      }
    });
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
