class TaskStep {
  final int? step;
  final String? name;
  final String? phase;
  final String details;

  const TaskStep({
    this.step,
    this.name,
    this.phase,
    required this.details,
  });

  factory TaskStep.fromJson(Map<String, dynamic> json) {
    return TaskStep(
      step: json['step'] as int?,
      name: json['name'] as String?,
      phase: json['phase'] as String?,
      details: json['details'] as String,
    );
  }
}
