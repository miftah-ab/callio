import 'package:flutter/material.dart';
import 'package:callio/themes/design_system.dart';
import 'package:callio/data/repositories.dart';
import 'package:callio/domain/models.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  final RuleRepository _repo = RuleRepository();
  List<Rule> _routines = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRoutines();
  }

  Future<void> _loadRoutines() async {
    final data = await _repo.getAll();
    if (mounted) {
      setState(() {
        _routines = data;
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
        title: const Text('Routines'),
        centerTitle: false,
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _routines.isEmpty 
              ? _buildEmptyState(context, colorScheme)
              : _buildRoutinesList(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Open Create Routine Bottom Sheet
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Routine Builder coming soon!')),
          );
        },
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('New Routine'),
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

  Widget _buildRoutinesList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(CallioDesign.spacing16),
      itemCount: _routines.length,
      separatorBuilder: (context, index) => const SizedBox(height: CallioDesign.spacing16),
      itemBuilder: (context, index) {
        final routine = _routines[index];
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
                      Text(
                        routine.name.isEmpty ? 'Custom Routine' : routine.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Switch(
                        value: routine.isActive,
                        onChanged: (val) {
                          // Toggle logic
                        },
                      ),
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
}
