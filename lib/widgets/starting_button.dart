import 'package:commongrounds/theme/typography.dart';
import 'package:flutter/material.dart';
import 'package:commongrounds/theme/colors.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double horizontalPadding;
  final double verticalPadding;
  final double borderRadius;
  final double fontSize;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.horizontalPadding = 80,
    this.verticalPadding = 15,
    this.borderRadius = 50,
    this.fontSize = 18,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.navbar,
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: 4,
      ),
      child: Text(
        text,
        style: AppTypography.button.copyWith(
          fontWeight: FontWeight.w900,
          fontSize: 18,
        ),
      ),
    );
  }
}
