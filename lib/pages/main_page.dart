import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import 'package:commongrounds/pages/dashboard_page.dart';
import 'package:commongrounds/pages/tasks_page.dart';
import 'package:commongrounds/pages/calendar_page.dart';
import 'package:commongrounds/pages/focus_mode_page.dart';
import 'package:commongrounds/pages/wasi_page.dart';
import 'package:commongrounds/pages/sign_in_page.dart';
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

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignInPage()),
        (route) => false,
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

  void _handleSwipeBack() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex -= 1);
    } else {
      // You’re on Dashboard already
      // Option A: do nothing
      // Option B: exit app (Android behavior):
      SystemNavigator.pop();
      // Option C: Navigator.maybePop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopNavbar(
        pageTitle: _pageTitles[_currentIndex],
        onProfileTap: () => Navigator.pushNamed(context, '/profile'),
        onNotificationTap: () => Navigator.pushNamed(context, '/notifications'),
        onLogoutTap: _logout,
      ),

      // ✅ Swipe right to go "back" (previous tab)
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: (details) {
          final v = details.primaryVelocity ?? 0;

          // Swipe right = back
          if (v > 300) {
            _handleSwipeBack();
          }
        },
        child: _pages[_currentIndex],
      ),

      bottomNavigationBar: BottomNavbar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
