import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:commongrounds/pages/dashboard_page.dart';
import 'package:commongrounds/pages/tasks_page.dart';
import 'package:commongrounds/pages/calendar_page.dart';
import 'package:commongrounds/pages/focus_mode_page.dart';
import 'package:commongrounds/pages/wasi_page.dart';
<<<<<<< HEAD
import 'package:commongrounds/pages/sign_in_page.dart';
=======
import 'package:commongrounds/pages/notifications_page.dart';
import 'package:commongrounds/pages/profile_page.dart';
>>>>>>> 4790bed27e8d1139bd4fa88cf9334766b96fd798
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
    setState(() => _currentIndex = index);
  }

  // ✅ LOGOUT FUNCTION
  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignInPage()),
        (route) => false, // removes all previous routes
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to log out. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNavbar(
        pageTitle: _pageTitles[_currentIndex],
        onProfileTap: () {
<<<<<<< HEAD
          // optional: go to profile page
        },
        onNotificationTap: () {
          // optional: go to notifications
=======
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
>>>>>>> 4790bed27e8d1139bd4fa88cf9334766b96fd798
        },
        onLogoutTap: _logout, // ✅ CONNECT LOGOUT
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavbar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
