import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:callio/themes/design_system.dart';
import 'package:callio/domain/models.dart';
import 'package:callio/presentation/providers/rule_provider.dart';
import 'package:callio/presentation/providers/template_provider.dart';
import 'package:callio/presentation/widgets/callio_bottom_sheet.dart';
import 'package:callio/presentation/widgets/callio_text_field.dart';

class RoutinesScreen extends ConsumerWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final asyncRules = ref.watch(rulesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Routines'),
        centerTitle: false,
      ),
      body: asyncRules.when(
        data: (routines) => routines.isEmpty
            ? _buildEmptyState(context, colorScheme)
            : _buildRoutinesList(context, ref, routines),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRoutineSheet(context, ref),
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('New Routine'),
      ),
    );
  }

  void _showRoutineSheet(BuildContext context, WidgetRef ref, {Rule? existingRule}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _RoutineEditorSheet(existingRule: existingRule),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(CallioDesign.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(CallioDesign.spacing32),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome_motion_rounded, size: 80, color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: CallioDesign.spacing32),
            Text(
              'No Routines Yet',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: CallioDesign.spacing16),
            Text(
              'Create a routine to automatically reply to missed calls based on who is calling and when.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutinesList(BuildContext context, WidgetRef ref, List<Rule> routines) {
    return ListView.separated(
      padding: const EdgeInsets.all(CallioDesign.spacing16),
      itemCount: routines.length,
      separatorBuilder: (context, index) => const SizedBox(height: CallioDesign.spacing16),
      itemBuilder: (context, index) {
        final routine = routines[index];
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(CallioDesign.radiusLarge),
            onTap: () => _showRoutineSheet(context, ref, existingRule: routine),
            child: Padding(
              padding: const EdgeInsets.all(CallioDesign.spacing24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          routine.name.isEmpty ? 'Custom Routine' : routine.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      Switch(
                        value: routine.isActive,
                        onChanged: (val) {
                          // Fast optimistic UI update could go here
                          final updated = Rule(
                            id: routine.id,
                            name: routine.name,
                            contactGroup: routine.contactGroup,
                            templateId: routine.templateId,
                            priority: routine.priority,
                            isActive: val,
                          );
                          ref.read(rulesProvider.notifier).saveRule(updated);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                        onPressed: () => _confirmDelete(context, ref, routine),
                      )
                    ],
                  ),
                  const SizedBox(height: CallioDesign.spacing8),
                  Row(
                    children: [
                      Icon(Icons.group_rounded, size: 16, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: CallioDesign.spacing8),
                      Text('Target: ${routine.contactGroup}', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: CallioDesign.spacing4),
                  Row(
                    children: [
                      Icon(Icons.flag_rounded, size: 16, color: Theme.of(context).colorScheme.secondary),
                      const SizedBox(width: CallioDesign.spacing8),
                      Text('Priority: ${routine.priority}', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Rule rule) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Routine?'),
        content: Text('Are you sure you want to delete "${rule.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && rule.id != null) {
      HapticFeedback.heavyImpact();
      ref.read(rulesProvider.notifier).deleteRule(rule.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Routine deleted.')));
      }
    }
  }
}

class _RoutineEditorSheet extends ConsumerStatefulWidget {
  final Rule? existingRule;

  const _RoutineEditorSheet({this.existingRule});

  @override
  ConsumerState<_RoutineEditorSheet> createState() => _RoutineEditorSheetState();
}

class _RoutineEditorSheetState extends ConsumerState<_RoutineEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _groupController;
  late int _priority;
  int? _selectedTemplateId;
  bool _hasUnsavedChanges = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingRule?.name ?? '');
    _groupController = TextEditingController(text: widget.existingRule?.contactGroup ?? '');
    _priority = widget.existingRule?.priority ?? 0;
    _selectedTemplateId = widget.existingRule?.templateId;

    void _markDirty() {
      if (!_hasUnsavedChanges) setState(() => _hasUnsavedChanges = true);
    }
    _nameController.addListener(_markDirty);
    _groupController.addListener(_markDirty);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTemplateId == null) {
      setState(() => _errorMessage = 'Please select a Response to send.');
      return;
    }
    
    setState(() => _errorMessage = null);

    final rule = Rule(
      id: widget.existingRule?.id,
      name: _nameController.text.trim(),
      contactGroup: _groupController.text.trim(),
      templateId: _selectedTemplateId!,
      priority: _priority,
      isActive: widget.existingRule?.isActive ?? true,
    );

    try {
      await ref.read(rulesProvider.notifier).saveRule(rule);
      HapticFeedback.lightImpact();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
      HapticFeedback.vibrate();
    }
  }

  @override
  Widget build(BuildContext context) {
    final templatesState = ref.watch(templatesProvider);

    return Form(
      key: _formKey,
      child: CallioBottomSheet(
        title: widget.existingRule == null ? 'New Routine' : 'Edit Routine',
        hasUnsavedChanges: _hasUnsavedChanges,
        onSave: _save,
        children: [
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(_errorMessage!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
            
          CallioTextField(
            controller: _nameController,
            labelText: 'Routine Name (e.g. Boss Call)',
            validator: (value) => value == null || value.trim().isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: CallioDesign.spacing16),
          CallioTextField(
            controller: _groupController,
            labelText: 'Target Number / Group',
            validator: (value) => value == null || value.trim().isEmpty ? 'Target is required' : null,
          ),
          const SizedBox(height: CallioDesign.spacing16),
          
          templatesState.when(
            data: (templates) {
              if (templates.isEmpty) {
                return const Text('Please create a Response first in the Responses tab.', style: TextStyle(color: Colors.red));
              }
              // Ensure selectedTemplateId is valid or default to first
              if (_selectedTemplateId == null || !templates.any((t) => t.id == _selectedTemplateId)) {
                _selectedTemplateId = templates.first.id;
              }
              return DropdownButtonFormField<int>(
                decoration: InputDecoration(
                  labelText: 'Response to send',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(CallioDesign.radiusMedium)),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                ),
                value: _selectedTemplateId,
                items: templates.map((t) => DropdownMenuItem(
                  value: t.id,
                  child: Text(t.name),
                )).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedTemplateId = val;
                    _hasUnsavedChanges = true;
                  });
                },
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (err, stack) => Text('Error loading templates: $err'),
          ),
          
          const SizedBox(height: CallioDesign.spacing16),
          Text('Priority (Higher executes first): $_priority'),
          Slider(
            value: _priority.toDouble(),
            min: 0,
            max: 100,
            divisions: 10,
            label: _priority.toString(),
            onChanged: (val) {
              setState(() {
                _priority = val.toInt();
                _hasUnsavedChanges = true;
              });
            },
          ),
        ],
      ),
    );
  }
}
