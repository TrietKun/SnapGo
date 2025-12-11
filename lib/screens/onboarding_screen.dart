import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:snapgo/blocs/settings/settings_bloc.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _skipToEnd() {
    _pageController.animateToPage(
      2,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finishOnboarding() {
    context.read<SettingsBloc>().add(CompleteOnboarding());
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button (hidden on last page)
            if (_currentPage < 2)
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skipToEnd,
                  child: Text(
                    l10n.skip,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else
              const SizedBox(height: 48),

            // PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: [
                  _OnboardingPage(
                    icon: Icons.camera_alt_rounded,
                    title: l10n.onboardingTitle1,
                    description: l10n.onboardingDesc1,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.1),
                      ],
                    ),
                  ),
                  _OnboardingPage(
                    icon: Icons.location_on_rounded,
                    title: l10n.onboardingTitle2,
                    description: l10n.onboardingDesc2,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.1),
                        Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                      ],
                    ),
                  ),
                  _OnboardingPage(
                    icon: Icons.favorite_rounded,
                    title: l10n.onboardingTitle3,
                    description: l10n.onboardingDesc3,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Page Indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: 3,
                effect: ExpandingDotsEffect(
                  activeDotColor: Theme.of(context).colorScheme.primary,
                  dotColor:
                      Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  dotHeight: 8,
                  dotWidth: 8,
                  expansionFactor: 4,
                  spacing: 8,
                ),
              ),
            ),

            // Bottom Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _currentPage == 2 ? _finishOnboarding : _nextPage,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _currentPage == 2 ? l10n.getStarted : l10n.next,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Gradient gradient;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with gradient background
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: gradient,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

          const SizedBox(height: 48),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}
