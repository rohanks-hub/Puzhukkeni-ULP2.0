wai  Widget _buildAlarmCard(BuildContext context, Alarm alarm) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
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

