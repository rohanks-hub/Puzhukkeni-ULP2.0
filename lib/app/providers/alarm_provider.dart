import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/alarm.dart';
import '../services/alarm_service.dart';

class AlarmProvider with ChangeNotifier {
  final List<Alarm> _alarms = [];
  final AlarmService _alarmService = AlarmService();
  BuildContext? _context;

  void setContext(BuildContext context) {
    _context = context;
  }

  List<Alarm> get alarms => List.unmodifiable(_alarms);

  void addAlarm(Alarm alarm) {
    _alarms.add(alarm);
    _sortAlarms();
    if (_context != null) {
      _alarmService.scheduleAlarm(_context!, alarm);
    }
    notifyListeners();
  }

  void deleteAlarm(String id) {
    _alarms.removeWhere((alarm) => alarm.id == id);
    _alarmService.cancelAlarm(id);
    notifyListeners();
  }

  void updateAlarm(Alarm updatedAlarm) {
    final index = _alarms.indexWhere((alarm) => alarm.id == updatedAlarm.id);
    if (index != -1) {
      _alarms[index] = updatedAlarm;
      _sortAlarms();
      if (_context != null) {
        _alarmService.scheduleAlarm(_context!, updatedAlarm);
      }
      notifyListeners();
    }
  }

  void toggleAlarm(String id) {
    final index = _alarms.indexWhere((alarm) => alarm.id == id);
    if (index != -1) {
      final alarm = _alarms[index];
      final updatedAlarm = alarm.copyWith(isActive: !alarm.isActive);
      _alarms[index] = updatedAlarm;

      if (updatedAlarm.isActive && _context != null) {
        _alarmService.scheduleAlarm(_context!, updatedAlarm);
      } else {
        _alarmService.cancelAlarm(id);
      }

      notifyListeners();
    }
  }

  void _sortAlarms() {
    _alarms.sort((a, b) => a.time.compareTo(b.time));
  }

  @override
  void dispose() {
    _alarmService.dispose();
    super.dispose();
  }
}
