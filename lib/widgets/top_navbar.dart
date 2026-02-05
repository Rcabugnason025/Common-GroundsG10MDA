import 'package:flutter/material.dart';
import 'package:commongrounds/theme/colors.dart';
import 'package:commongrounds/theme/typography.dart';

class TopNavbar extends StatelessWidget implements PreferredSizeWidget {
  final String pageTitle;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onLogoutTap;

  const TopNavbar({
    super.key,
    required this.pageTitle,
    this.onProfileTap,
    this.onNotificationTap,
    this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.navbar.withOpacity(0.6),
      elevation: 0,
      title: Text(
        pageTitle,
        style: AppTypography.heading2.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: AppColors.icon),
          onPressed: onNotificationTap,
        ),
        IconButton(
          icon: const Icon(Icons.person_outlined, color: AppColors.icon),
          onPressed: onProfileTap,
        ),
        IconButton(
        tooltip: "Logout",
        icon: const Icon(Icons.logout, color: AppColors.icon),
        onPressed: onLogoutTap,
      ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}