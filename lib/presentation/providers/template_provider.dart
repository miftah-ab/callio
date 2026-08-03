import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:callio/data/repositories.dart';
import 'package:callio/domain/models.dart';

final templateRepositoryProvider = Provider((ref) => TemplateRepository());

final templatesProvider = AsyncNotifierProvider<TemplatesNotifier, List<Template>>(
  () => TemplatesNotifier(),
);

class TemplatesNotifier extends AsyncNotifier<List<Template>> {
  @override
  Future<List<Template>> build() async {
    return _fetchTemplates();
  }

  Future<List<Template>> _fetchTemplates() async {
    final repo = ref.read(templateRepositoryProvider);
    return await repo.getAll();
  }

  Future<void> saveTemplate(Template template) async {
    final repo = ref.read(templateRepositoryProvider);
    
    // Duplicate name validation
    final currentTemplates = state.value ?? [];
    if (template.id == null && currentTemplates.any((t) => t.name.toLowerCase() == template.name.toLowerCase())) {
      throw Exception('A response with this name already exists.');
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repo.insert(template);
      return _fetchTemplates();
    });
  }

  Future<void> deleteTemplate(int id) async {
    final repo = ref.read(templateRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repo.delete(id);
      return _fetchTemplates();
    });
  }
}
