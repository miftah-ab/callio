import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:callio/data/repositories.dart';
import 'package:callio/domain/models.dart';

final ruleRepositoryProvider = Provider((ref) => RuleRepository());

final rulesProvider = AsyncNotifierProvider<RulesNotifier, List<Rule>>(
  () => RulesNotifier(),
);

class RulesNotifier extends AsyncNotifier<List<Rule>> {
  @override
  Future<List<Rule>> build() async {
    return _fetchRules();
  }

  Future<List<Rule>> _fetchRules() async {
    final repo = ref.read(ruleRepositoryProvider);
    return await repo.getAll();
  }

  Future<void> saveRule(Rule rule) async {
    final repo = ref.read(ruleRepositoryProvider);

    // Duplicate name validation
    final currentRules = state.value ?? [];
    if (rule.id == null && currentRules.any((r) => r.name.toLowerCase() == rule.name.toLowerCase())) {
      throw Exception('A routine with this name already exists.');
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repo.insert(rule);
      return _fetchRules();
    });
  }

  Future<void> deleteRule(int id) async {
    final repo = ref.read(ruleRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repo.delete(id);
      return _fetchRules();
    });
  }
}
