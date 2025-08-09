import 'package:flutter/foundation.dart';
import '../models/alarm.dart';

class AlarmProvider with ChangeNotifier {
  final List<Alarm> _alarms = [];

  List<Alarm> get alarms => List.unmodifiable(_alarms);

  void addAlarm(Alarm alarm) {
    _alarms.add(alarm);
    _sortAlarms();
    notifyListeners();
  }

  void deleteAlarm(String id) {
    _alarms.removeWhere((alarm) => alarm.id == id);
    notifyListeners();
  }

  void updateAlarm(Alarm updatedAlarm) {
    final index = _alarms.indexWhere((alarm) => alarm.id == updatedAlarm.id);
    if (index != -1) {
      _alarms[index] = updatedAlarm;
      _sortAlarms();
      notifyListeners();
    }
  }

  void toggleAlarm(String id) {
    final index = _alarms.indexWhere((alarm) => alarm.id == id);
    if (index != -1) {
      final alarm = _alarms[index];
      _alarms[index] = alarm.copyWith(isActive: !alarm.isActive);
      notifyListeners();
    }
  }

  void _sortAlarms() {
    _alarms.sort((a, b) => a.time.compareTo(b.time));
  }
}
