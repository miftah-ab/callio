import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:callio/themes/design_system.dart';
import 'package:callio/main.dart'; // To navigate to MainLayout

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      title: 'Never Miss an Opportunity',
      description: 'Callio intelligently replies to missed calls when you are busy, driving, or in a meeting.',
      icon: Icons.auto_awesome_rounded,
    ),
    _OnboardingPage(
      title: '100% Private & Offline',
      description: 'Your contacts and call logs never leave your device. Callio processes everything entirely offline.',
      icon: Icons.security_rounded,
    ),
    _OnboardingPage(
      title: 'Let\'s Get Started',
      description: 'To automate your replies, Callio needs permission to detect missed calls and send SMS messages.',
      icon: Icons.shield_rounded,
      isFinalPage: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              final page = _pages[index];
              return Padding(
                padding: const EdgeInsets.all(CallioDesign.spacing32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(CallioDesign.spacing32),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(page.icon, size: 80, color: colorScheme.onPrimaryContainer),
                    ),
                    const SizedBox(height: CallioDesign.spacing48),
                    Text(
                      page.title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: CallioDesign.spacing16),
                    Text(
                      page.description,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
          Positioned(
            bottom: CallioDesign.spacing48,
            left: CallioDesign.spacing32,
            right: CallioDesign.spacing32,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Page Indicators
                Row(
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: CallioDesign.durationFast,
                      margin: const EdgeInsets.only(right: CallioDesign.spacing8),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                // Next / Action Button
                FilledButton(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: CallioDesign.spacing32, vertical: CallioDesign.spacing16),
                  ),
                  onPressed: () async {
                    if (_currentPage == _pages.length - 1) {
                      await _requestPermissions();
                    } else {
                      _pageController.nextPage(
                        duration: CallioDesign.durationNormal,
                        curve: CallioDesign.curveStandard,
                      );
                    }
                  },
                  child: Text(_currentPage == _pages.length - 1 ? 'Grant Permissions' : 'Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestPermissions() async {
    final status = await [
      Permission.phone,
      Permission.sms,
      Permission.contacts,
    ].request();

    if (mounted) {
      // Regardless of exact grant status for now, move to dashboard.
      // In production, we'd handle denied states with a polite explanation.
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainLayout(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }
}

class _OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final bool isFinalPage;

  _OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    this.isFinalPage = false,
  });
}
