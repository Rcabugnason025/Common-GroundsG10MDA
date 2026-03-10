import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:commongrounds/theme/colors.dart';
import 'package:commongrounds/theme/typography.dart';
import 'package:commongrounds/widgets/starting_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Symbols.owl, size: 96, color: Color(0xFF0D47A1)),
              const SizedBox(height: 16),
              Text('Welcome to CommonGrounds', style: AppTypography.heading1),
              const SizedBox(height: 12),
              Text(
                'Plan tasks, track progress, and stay focused. Your data can be stored locally or synced to the cloud.',
                style: AppTypography.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _FeatureChip(icon: Icons.check_circle, label: 'Create tasks'),
                  const SizedBox(width: 8),
                  _FeatureChip(icon: Icons.sync, label: 'Local & Cloud'),
                  const SizedBox(width: 8),
                  _FeatureChip(icon: Icons.insights, label: 'Study tools'),
                ],
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Continue to Dashboard',
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/main');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.navbar.withAlpha((0.12 * 255).round()),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.navbar),
          const SizedBox(width: 6),
          Text(label, style: AppTypography.caption),
        ],
      ),
    );
  }
}
