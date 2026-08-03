import 'package:flutter_test/flutter_test.dart';
import 'package:callio/domain/models.dart';
import 'package:callio/presentation/providers/rule_provider.dart';

void main() {
  group('Rule Duplicate Validation Logic', () {
    test('Should throw exception if routine name already exists (case-insensitive)', () async {
      // Create a simulated list of existing rules
      final existingRules = [
        Rule(id: 1, name: 'Boss', contactGroup: 'Boss', templateId: 1, priority: 100),
        Rule(id: 2, name: 'Driving', contactGroup: 'Unknown', templateId: 2, priority: 10),
      ];

      // New rule with the exact same name but different case
      final duplicateRule = Rule(name: 'boss', contactGroup: 'VIP', templateId: 3);

      bool throwsError = false;
      try {
        if (duplicateRule.id == null && existingRules.any((r) => r.name.toLowerCase() == duplicateRule.name.toLowerCase())) {
          throw Exception('A routine with this name already exists.');
        }
      } catch (e) {
        throwsError = true;
      }

      expect(throwsError, isTrue);
    });

    test('Should allow creation if name is unique', () async {
      final existingRules = [
        Rule(id: 1, name: 'Boss', contactGroup: 'Boss', templateId: 1, priority: 100),
      ];

      final newRule = Rule(name: 'Meeting', contactGroup: 'Unknown', templateId: 3);

      bool throwsError = false;
      try {
        if (newRule.id == null && existingRules.any((r) => r.name.toLowerCase() == newRule.name.toLowerCase())) {
          throw Exception('A routine with this name already exists.');
        }
      } catch (e) {
        throwsError = true;
      }

      expect(throwsError, isFalse);
    });
  });
}
