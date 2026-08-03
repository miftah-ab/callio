import 'package:flutter/material.dart';
import 'package:callio/themes/design_system.dart';
import 'package:callio/data/repositories.dart';
import 'package:callio/domain/models.dart';

class ResponsesScreen extends StatefulWidget {
  const ResponsesScreen({super.key});

  @override
  State<ResponsesScreen> createState() => _ResponsesScreenState();
}

class _ResponsesScreenState extends State<ResponsesScreen> {
  final TemplateRepository _repo = TemplateRepository();
  List<Template> _responses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResponses();
  }

  Future<void> _loadResponses() async {
    final data = await _repo.getAll();
    if (mounted) {
      setState(() {
        _responses = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Responses'),
        centerTitle: false,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _responses.isEmpty 
              ? _buildEmptyState(context, colorScheme)
              : _buildResponsesList(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateResponseSheet(context),
        icon: const Icon(Icons.add_comment_rounded),
        label: const Text('New Response'),
      ),
    );
  }

  void _showCreateResponseSheet(BuildContext context) {
    final nameController = TextEditingController();
    final contentController = TextEditingController();
    bool isDefault = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: CallioDesign.spacing24,
                right: CallioDesign.spacing24,
                top: CallioDesign.spacing24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('New Response', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: CallioDesign.spacing24),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Response Name (e.g. Driving)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: CallioDesign.spacing16),
                  TextField(
                    controller: contentController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Message Body',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: CallioDesign.spacing16),
                  SwitchListTile(
                    title: const Text('Set as Default'),
                    subtitle: const Text('Use this if no other routine matches'),
                    value: isDefault,
                    onChanged: (val) => setSheetState(() => isDefault = val),
                  ),
                  const SizedBox(height: CallioDesign.spacing24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        if (nameController.text.isNotEmpty && contentController.text.isNotEmpty) {
                          await _repo.insert(Template(
                            name: nameController.text,
                            content: contentController.text,
                            isDefault: isDefault,
                          ));
                          if (context.mounted) Navigator.pop(context);
                          _loadResponses();
                        }
                      },
                      child: const Text('Save Response'),
                    ),
                  ),
                  const SizedBox(height: CallioDesign.spacing24),
                ],
              ),
            );
          },
        );
      },
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

  Widget _buildResponsesList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(CallioDesign.spacing16),
      itemCount: _responses.length,
      separatorBuilder: (context, index) => const SizedBox(height: CallioDesign.spacing16),
      itemBuilder: (context, index) {
        final response = _responses[index];
        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(CallioDesign.radiusLarge),
            onTap: () {},
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
                    ],
                  ),
                  const SizedBox(height: CallioDesign.spacing12),
                  Container(
                    padding: const EdgeInsets.all(CallioDesign.spacing16),
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
}
