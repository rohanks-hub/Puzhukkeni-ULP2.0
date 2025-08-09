import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/alarm_provider.dart';
import '../models/alarm.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Provider.of<AlarmProvider>(context, listen: false).setContext(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Puzukkeni',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Consumer<AlarmProvider>(
          builder: (context, alarmProvider, child) {
            if (alarmProvider.alarms.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.alarm_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No alarms yet',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap + to add your first alarm',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      ),
                    ),
                  ],
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAlarmDialog(context),
        child: const Icon(Icons.add, size: 32),
      ),
    );
  }

  Widget _buildAlarmCard(BuildContext context, Alarm alarm) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showAddAlarmDialog(context, alarm),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('HH:mm').format(alarm.time),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: alarm.isActive
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.primary.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          alarm.label,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: alarm.isActive
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: alarm.isActive,
                    onChanged: (value) {
                      Provider.of<AlarmProvider>(context, listen: false)
                          .toggleAlarm(alarm.id);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: Theme.of(context).colorScheme.error,
                    onPressed: () {
                      Provider.of<AlarmProvider>(context, listen: false)
                          .deleteAlarm(alarm.id);
                    },
                  ),
                ],
              ),
            ],
          ),
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
