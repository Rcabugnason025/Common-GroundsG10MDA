/// Validation service for task forms
class TaskValidationService {
  /// Validates task title
  /// Returns error message if invalid, null if valid
  static String? validateTitle(String value) {
    if (value.trim().isEmpty) return 'Task title is required';
    if (value.trim().length < 3) return 'Title must be at least 3 characters';
    if (value.trim().length > 100) return 'Title must be less than 100 characters';
    return null;
  }

  /// Validates task subject
  /// Returns error message if invalid, null if valid
  static String? validateSubject(String value) {
    if (value.trim().isEmpty) return 'Subject is required';
    if (value.trim().length < 3) return 'Subject must be at least 3 characters';
    if (value.trim().length > 200) return 'Subject must be less than 200 characters';
    return null;
  }

  /// Validates task deadline date
  /// Returns error message if invalid, null if valid
  static String? validateDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(date.year, date.month, date.day);
    if (selected.isBefore(today)) return 'Due date cannot be in the past';
    return null;
  }
}
