import 'package:flutter/material.dart';
import 'package:commongrounds/theme/colors.dart';
import 'package:commongrounds/theme/typography.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const CustomTextField({
    super.key,
    required this.label,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final textField = TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: AppTypography.body,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.bodySmall,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.icon) : null,
        filled: true,
        fillColor: AppColors.textField.withAlpha((0.2 * 255).round()),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.textField, width: 2),
        ),
      ),
    );

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(vertical:8),
      child: SizedBox(
        width: width,
        height: height,
        child: textField,
      ),
    );
  }
}
