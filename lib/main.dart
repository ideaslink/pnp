import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/dashboard_screen.dart';
import 'screens/detected_tasks_screen.dart';
import 'screens/task_detail_call_screen.dart';
import 'screens/task_detail_navigate_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/history_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/menu_screen.dart';

void main() {
  runApp(const PointAndPlayApp());
}

class PointAndPlayApp extends StatelessWidget {
  const PointAndPlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Point & Play',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardScreen(),
        '/detected-tasks': (context) => const DetectedTasksScreen(),
        '/task-detail-call': (context) => const TaskDetailCallScreen(),
        '/task-detail-navigate': (context) => const TaskDetailNavigateScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/history': (context) => const HistoryScreen(),
        '/privacy': (context) => const PrivacyScreen(),
        '/menu': (context) => const MenuScreen(),
      },
    );
  }
}
