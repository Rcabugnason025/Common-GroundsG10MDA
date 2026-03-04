import 'package:flutter/material.dart';
import 'package:commongrounds/theme/colors.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: AppColors.navbar.withAlpha((0.6 * 255).round()),
      selectedItemColor: AppColors.icon,
      unselectedItemColor: AppColors.icon,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.format_list_bulleted), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.today), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.timer), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.flutter_dash), label: ''),
      ],
    );
  }
}
