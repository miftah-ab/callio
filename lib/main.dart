import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:callio/themes/design_system.dart';
import 'package:callio/presentation/onboarding_screen.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  runApp(
    const ProviderScope(
      child: CallioApp(),
    ),
  );
}

class CallioApp extends ConsumerWidget {
  const CallioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = CallioDesign.getTextTheme(context);
    
    // Using a sophisticated indigo seed color for the premium feel
    final lightScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5), brightness: Brightness.light);
    final darkScheme = ColorScheme.fromSeed(seedColor: const Color(0xFF4F46E5), brightness: Brightness.dark);

    return MaterialApp(
      title: 'Callio',
      debugShowCheckedModeBanner: false,
      theme: CallioDesign.buildTheme(lightScheme, textTheme),
      darkTheme: CallioDesign.buildTheme(darkScheme, textTheme),
      themeMode: ThemeMode.system,
      home: const Callio3DSplashScreen(),
    );
  }
}

class Callio3DSplashScreen extends StatefulWidget {
  const Callio3DSplashScreen({super.key});

  @override
  State<Callio3DSplashScreen> createState() => _Callio3DSplashScreenState();
}

class _Callio3DSplashScreenState extends State<Callio3DSplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));
    
    _rotationAnimation = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.8, 1.0, curve: Curves.easeIn)),
    );

    _controller.forward().then((_) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 800),
          pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Deep elegant slate matching native splash
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Transform(
                alignment: FractionalOffset.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.002) // Perspective for 3D effect
                  ..rotateX(_rotationAnimation.value)
                  ..rotateY(_rotationAnimation.value * 0.5)
                  ..scale(_scaleAnimation.value),
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(color: const Color(0xFF4F46E5).withOpacity(0.5), width: 2),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF4F46E5).withOpacity(0.5), blurRadius: 40, spreadRadius: 10),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.forum_rounded, size: 72, color: Colors.white),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardScreen(),
    PlaceholderScreen(title: 'Routines'),
    PlaceholderScreen(title: 'Responses'),
    PlaceholderScreen(title: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    // 2026 Android 16 Standards: Adaptive Layouts for Foldables & Tablets
    final isWideScreen = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      body: Row(
        children: [
          if (isWideScreen)
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
              },
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.auto_awesome_motion_outlined),
                  selectedIcon: Icon(Icons.auto_awesome_motion_rounded),
                  label: Text('Routines'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.forum_outlined),
                  selectedIcon: Icon(Icons.forum_rounded),
                  label: Text('Responses'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings_rounded),
                  label: Text('Settings'),
                ),
              ],
            ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: isWideScreen
          ? null
          : NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.auto_awesome_motion_outlined),
                  selectedIcon: Icon(Icons.auto_awesome_motion_rounded),
                  label: 'Routines',
                ),
                NavigationDestination(
                  icon: Icon(Icons.forum_outlined),
                  selectedIcon: Icon(Icons.forum_rounded),
                  label: 'Responses',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings_rounded),
                  label: 'Settings',
                ),
              ],
            ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  bool isEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Callio'),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: CallioDesign.spacing16),
                child: Switch(
                  value: isEnabled,
                  onChanged: (val) {
                    setState(() => isEnabled = val);
                  },
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(CallioDesign.spacing16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildStatusHero(context, colorScheme),
                const SizedBox(height: CallioDesign.spacing32),
                Text(
                  'Overview',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: CallioDesign.spacing16),
                Row(
                  children: [
                    Expanded(child: _buildStatCard(context, '12', 'Missed Calls', Icons.phone_missed)),
                    const SizedBox(width: CallioDesign.spacing16),
                    Expanded(child: _buildStatCard(context, '4', 'Auto-Replies', Icons.send)),
                  ],
                ),
                const SizedBox(height: CallioDesign.spacing32),
                Text(
                  'Recent Activity',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: CallioDesign.spacing16),
                _buildActivityTile(context, 'Mom', 'Sent "In a meeting"', '10 mins ago'),
                _buildActivityTile(context, 'Unknown Number', 'Ignored based on rules', '1 hour ago'),
                _buildActivityTile(context, 'Boss', 'Sent "Driving right now"', 'Yesterday'),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('New Rule'),
      ),
    );
  }

  Widget _buildStatusHero(BuildContext context, ColorScheme colorScheme) {
    return AnimatedContainer(
      duration: CallioDesign.durationNormal,
      curve: CallioDesign.curveStandard,
      padding: const EdgeInsets.all(CallioDesign.spacing32),
      decoration: BoxDecoration(
        color: isEnabled ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(CallioDesign.radiusLarge),
      ),
      child: Column(
        children: [
          Icon(
            isEnabled ? Icons.shield_rounded : Icons.shield_outlined,
            size: 64,
            color: isEnabled ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: CallioDesign.spacing16),
          Text(
            isEnabled ? 'Protection Active' : 'Protection Paused',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: isEnabled ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: CallioDesign.spacing8),
          Text(
            isEnabled ? 'Callio is silently monitoring missed calls in the background.' : 'No auto-replies will be sent.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isEnabled ? colorScheme.onPrimaryContainer.withOpacity(0.8) : colorScheme.onSurfaceVariant.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label, IconData icon) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(CallioDesign.spacing24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const SizedBox(height: CallioDesign.spacing16),
            Text(value, style: theme.textTheme.headlineMedium),
            Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(BuildContext context, String title, String subtitle, String time) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: CallioDesign.spacing16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: theme.colorScheme.secondaryContainer,
            child: Icon(Icons.person, color: theme.colorScheme.onSecondaryContainer),
          ),
          const SizedBox(width: CallioDesign.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          Text(time, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text('$title Screen', style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}
