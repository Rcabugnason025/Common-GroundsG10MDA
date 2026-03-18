import 'package:flutter_test/flutter_test.dart';
import 'package:commongrounds/services/task_validation_service.dart';

void main() {
  group('TaskValidationService', () {
    test('TC-006 Add Task - Validation (missing title)', () {
      final err = TaskValidationService.validateTitle('');
      expect(err, isNotNull);
    });

    test('TC-006 Add Task - Validation (missing subject)', () {
      final err = TaskValidationService.validateSubject('');
      expect(err, isNotNull);
    });

    test('Title validation accepts normal title', () {
      final err = TaskValidationService.validateTitle('Study Flutter');
      expect(err, isNull);
    });

    test('Subject validation accepts normal subject', () {
      final err = TaskValidationService.validateSubject('Mobile Development');
      expect(err, isNull);
    });

    test('Date validation rejects past dates', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final err = TaskValidationService.validateDate(yesterday);
      expect(err, isNotNull);
    });
  });
}

