import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/alarm_provider.dart';
import '../models/alarm.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize alarm provider with context
    Provider.of<AlarmProvider>(context, listen: false).setContext(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarm App'),
      ),
      body: Consumer<AlarmProvider>(
        builder: (context, alarmProvider, child) {
          if (alarmProvider.alarms.isEmpty) {
            return const Center(
              child: Text(
                'No alarms set yet',
                style: TextStyle(fontSize: 18),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alarmProvider.alarms.length,
            itemBuilder: (context, index) {
              final alarm = alarmProvider.alarms[index];
              return _buildAlarmCard(context, alarm);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAlarmDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAlarmCard(BuildContext context, Alarm alarm) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          DateFormat('HH:mm').format(alarm.time),
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: alarm.isActive ? Colors.black : Colors.grey,
          ),
        ),
        subtitle: Text(
          alarm.label,
          style: TextStyle(
            fontSize: 16,
            color: alarm.isActive ? Colors.black87 : Colors.grey,
          ),
        ),
        leading: Switch(
          value: alarm.isActive,
          onChanged: (bool value) {
            Provider.of<AlarmProvider>(context, listen: false)
                .toggleAlarm(alarm.id);
          },
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showAddAlarmDialog(context, alarm),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                Provider.of<AlarmProvider>(context, listen: false)
                    .deleteAlarm(alarm.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddAlarmDialog(BuildContext context, [Alarm? existingAlarm]) async {
    TimeOfDay? selectedTime = existingAlarm != null
        ? TimeOfDay.fromDateTime(existingAlarm.time)
        : null;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null && context.mounted) {
      final now = DateTime.now();
      var dateTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );

      // If the time is earlier than now, set it for tomorrow
      if (dateTime.isBefore(now)) {
        dateTime = dateTime.add(const Duration(days: 1));
      }

      final label = await _showLabelDialog(context, existingAlarm?.label);

      if (label != null && context.mounted) {
        final alarm = Alarm(
          id: existingAlarm?.id,
          time: dateTime,
          label: label,
        );

        if (existingAlarm != null) {
          Provider.of<AlarmProvider>(context, listen: false).updateAlarm(alarm);
        } else {
          Provider.of<AlarmProvider>(context, listen: false).addAlarm(alarm);
        }
      }
    }
  }

  Future<String?> _showLabelDialog(BuildContext context, String? initialLabel) async {
    final controller = TextEditingController(text: initialLabel);

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Alarm Label'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter alarm label',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
