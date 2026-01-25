import 'package:flutter/material.dart';

class ClassModel {
  final String subject;
  final String time;
  final String day;
  final String instructor;
  final IconData icon;

  const ClassModel({
    required this.subject,
    required this.time,
    required this.day,
    required this.instructor,
    required this.icon
  });
}
