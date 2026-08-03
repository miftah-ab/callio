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
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Response Editor coming soon!')),
          );
        },
        icon: const Icon(Icons.add_comment_rounded),
        label: const Text('New Response'),
      ),
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
