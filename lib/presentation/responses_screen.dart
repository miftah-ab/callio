import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:callio/themes/design_system.dart';
import 'package:callio/domain/models.dart';
import 'package:callio/presentation/providers/template_provider.dart';
import 'package:callio/presentation/widgets/callio_bottom_sheet.dart';
import 'package:callio/presentation/widgets/callio_text_field.dart';

class ResponsesScreen extends ConsumerWidget {
  const ResponsesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final asyncTemplates = ref.watch(templatesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Responses'),
        centerTitle: false,
      ),
      body: asyncTemplates.when(
        data: (responses) => responses.isEmpty
            ? _buildEmptyState(context, colorScheme)
            : _buildResponsesList(context, ref, responses),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showResponseSheet(context, ref),
        icon: const Icon(Icons.add_comment_rounded),
        label: const Text('New Response'),
      ),
    );
  }

  void _showResponseSheet(BuildContext context, WidgetRef ref, {Template? existingTemplate}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ResponseEditorSheet(existingTemplate: existingTemplate),
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
              child: Icon(Icons.forum_rounded, size: 80, color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: CallioDesign.spacing32),
            Text(
              'No Responses Yet',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: CallioDesign.spacing16),
            Text(
              'Draft custom messages that Callio will send when you miss a call.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsesList(BuildContext context, WidgetRef ref, List<Template> responses) {
    return ListView.separated(
      padding: const EdgeInsets.all(CallioDesign.spacing16),
      itemCount: responses.length,
      separatorBuilder: (context, index) => const SizedBox(height: CallioDesign.spacing16),
      itemBuilder: (context, index) {
        final response = responses[index];
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(CallioDesign.radiusLarge),
            onTap: () => _showResponseSheet(context, ref, existingTemplate: response),
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
                          response.name.isEmpty ? 'Custom Response' : response.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      if (response.isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Default',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                        onPressed: () => _confirmDelete(context, ref, response),
                      )
                    ],
                  ),
                  const SizedBox(height: CallioDesign.spacing12),
                  Container(
                    padding: const EdgeInsets.all(CallioDesign.spacing16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(CallioDesign.radiusMedium),
                    ),
                    child: Text(
                      '"${response.content}"',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Template response) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Response?'),
        content: Text('Are you sure you want to delete "${response.name}"?'),
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

    if (confirm == true && response.id != null) {
      HapticFeedback.heavyImpact();
      ref.read(templatesProvider.notifier).deleteTemplate(response.id!);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Response deleted.')));
      }
    }
  }
}

class _ResponseEditorSheet extends ConsumerStatefulWidget {
  final Template? existingTemplate;

  const _ResponseEditorSheet({this.existingTemplate});

  @override
  ConsumerState<_ResponseEditorSheet> createState() => _ResponseEditorSheetState();
}

class _ResponseEditorSheetState extends ConsumerState<_ResponseEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _contentController;
  late bool _isDefault;
  bool _hasUnsavedChanges = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingTemplate?.name ?? '');
    _contentController = TextEditingController(text: widget.existingTemplate?.content ?? '');
    _isDefault = widget.existingTemplate?.isDefault ?? false;

    void _markDirty() {
      if (!_hasUnsavedChanges) setState(() => _hasUnsavedChanges = true);
    }
    _nameController.addListener(_markDirty);
    _contentController.addListener(_markDirty);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _errorMessage = null);

    final template = Template(
      id: widget.existingTemplate?.id,
      name: _nameController.text.trim(),
      content: _contentController.text.trim(),
      isDefault: _isDefault,
    );

    try {
      await ref.read(templatesProvider.notifier).saveTemplate(template);
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
    return Form(
      key: _formKey,
      child: CallioBottomSheet(
        title: widget.existingTemplate == null ? 'New Response' : 'Edit Response',
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
            labelText: 'Response Name (e.g. Driving)',
            validator: (value) => value == null || value.trim().isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: CallioDesign.spacing16),
          CallioTextField(
            controller: _contentController,
            labelText: 'Message Body',
            maxLines: 3,
            maxLength: 160,
            validator: (value) => value == null || value.trim().isEmpty ? 'Message body is required' : null,
          ),
          const SizedBox(height: CallioDesign.spacing16),
          SwitchListTile(
            title: const Text('Set as Default'),
            subtitle: const Text('Use this if no other routine matches'),
            value: _isDefault,
            onChanged: (val) {
              setState(() {
                _isDefault = val;
                _hasUnsavedChanges = true;
              });
            },
          ),
        ],
      ),
    );
  }
}
