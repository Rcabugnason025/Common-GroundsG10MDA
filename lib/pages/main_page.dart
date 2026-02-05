import 'package:flutter/material.dart';
import 'package:commongrounds/pages/dashboard_page.dart';
import 'package:commongrounds/pages/tasks_page.dart';
import 'package:commongrounds/pages/calendar_page.dart';
import 'package:commongrounds/pages/focus_mode_page.dart';
import 'package:commongrounds/pages/wasi_page.dart';
import 'package:commongrounds/pages/notifications_page.dart';
import 'package:commongrounds/pages/profile_page.dart';
import 'package:commongrounds/widgets/top_navbar.dart';
import 'package:commongrounds/widgets/bottom_navbar.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<String> _pageTitles = [
    "Dashboard",
    "Tasks",
    "Calendar",
    "Focus Mode",
    "Wasi AI",
  ];

  final List<Widget> _pages = const [
    DashboardPage(),
    TasksPage(),
    CalendarPage(),
    FocusModePage(),
    WasiPage(),
  ];

  void _onNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNavbar(
        pageTitle: _pageTitles[_currentIndex],
        onProfileTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          ).then(
            (_) => setState(() {}),
          ); // Refresh to update profile icon if changed
        },
        onNotificationTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NotificationsPage()),
          );
        },
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavbar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
