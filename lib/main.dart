import 'package:flutter/material.dart';
import 'app/main_app.dart';
import 'app/services/alarm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AlarmService.initialize();
  runApp(const MainApp());
}
