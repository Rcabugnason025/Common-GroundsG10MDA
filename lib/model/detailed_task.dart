import 'package:flutter/material.dart';
import 'package:commongrounds/model/task_step.dart';

class DetailedTask {
  final String? id;
  final String title;
  final String subject;
  final List<TaskStep>? detailedSteps;
  final String? simpleDescription;
  final DateTime deadline;
  final String priority;
  final String status;
  final double progress;
  final IconData icon;
  final String category;

  DetailedTask({
    this.id,
    required this.title,
    required this.subject,
    this.detailedSteps,
    this.simpleDescription,
    required this.deadline,
    required this.priority,
    required this.status,
    required this.progress,
    required this.icon,
    required this.category,
  }) : assert(
  (detailedSteps == null && simpleDescription != null) ||
      (detailedSteps != null && simpleDescription == null),
  'Task must have EITHER detailedSteps (List<TaskStep>) OR a simpleDescription (String).',
  );

  factory DetailedTask.fromJson(Map<String, dynamic> json) {
    List<TaskStep>? steps;
    String? descriptionString;

    final descriptionData = json['description'];

    if (descriptionData is List) {
      steps = descriptionData.map((stepJson) => TaskStep.fromJson(stepJson)).toList();
    } else if (descriptionData is String) {
      descriptionString = descriptionData;
    }

    final progressValue = (json['progress'] is int)
        ? (json['progress'] as int).toDouble()
        : json['progress'] as double;

    return DetailedTask(
      id: json['id']?.toString(),
      title: json['title'] as String,
      subject: json['subject'] as String,
      detailedSteps: steps,
      simpleDescription: descriptionString,
      deadline: DateTime.parse(json['deadline'] as String),
      status: json['status'] as String,
      priority: json['priority'] as String,
      progress: progressValue,
      icon: Icons.assignment,
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    final descriptionData = detailedSteps != null
        ? detailedSteps!.map((e) => e.toJson()).toList()
        : simpleDescription;
    final map = {
      'title': title,
      'subject': subject,
      'description': descriptionData,
      'deadline': deadline.toIso8601String(),
      'priority': priority,
      'status': status,
      'progress': progress,
      'category': category,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  DetailedTask copyWith({
    String? id,
    String? title,
    String? subject,
    List<TaskStep>? detailedSteps,
    String? simpleDescription,
    DateTime? deadline,
    String? priority,
    String? status,
    double? progress,
    IconData? icon,
    String? category,
  }) {
    return DetailedTask(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      detailedSteps: detailedSteps ?? this.detailedSteps,
      simpleDescription: simpleDescription ?? this.simpleDescription,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      icon: icon ?? this.icon,
      category: category ?? this.category,
    );
  }
}
