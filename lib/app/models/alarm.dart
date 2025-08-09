import 'package:uuid/uuid.dart';

class Alarm {
  final String id;
  final DateTime time;
  final String label;
  final bool isActive;

  Alarm({
    String? id,
    required this.time,
    required this.label,
    this.isActive = true,
  }) : id = id ?? const Uuid().v4();

  Alarm copyWith({
    DateTime? time,
    String? label,
    bool? isActive,
  }) {
    return Alarm(
      id: this.id,
      time: time ?? this.time,
      label: label ?? this.label,
      isActive: isActive ?? this.isActive,
    );
  }
}
