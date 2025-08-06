import 'package:chpsmamacare_main01/screens/home_screen.dart';
import 'package:chpsmamacare_main01/utils/app_theme.dart';
import 'package:chpsmamacare_main01/utils/illustration_paths.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      image: Image.asset(IllustrationPaths.onboarding1),
      title: 'Track Pregnancies',
      description:
          'Easily register and monitor pregnancy progress with our simple, offline-first system designed for rural healthcare workers.',
      color: AppColors.primary,
    ),
    OnboardingPage(
      image: Image.asset(IllustrationPaths.onboarding2),
      title: 'Identify Danger Signs',
      description:
          'Quick checklist to identify maternal danger signs early and take immediate action to save lives.',
      color: AppColors.accent,
    ),
    OnboardingPage(
      image: Image.asset(IllustrationPaths.onboarding3),
      title: 'Emergency Referrals',
      description:
          'Access emergency guidelines and referral contacts even without internet connection.',
      color: AppColors.secondary,
    ),
    OnboardingPage(
      image: Image.asset(IllustrationPaths.onboarding4, fit: BoxFit.contain),
      title: 'Works Offline',
      description:
          'All your data is stored locally. No internet? No problem! Continue providing quality care anywhere.',
      color: AppColors.primary,
    ),
  ];

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Only on last page, route to HomeScreen
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _completeOnboarding() async {
    final settingsBox = Hive.box('app_settings');
    await settingsBox.put('has_seen_onboarding', true);
    await settingsBox.flush();

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with skip button indicators
            Padding(
              padding: EdgeInsetsGeometry.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 60),
                  // Page Indicators
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentPage == index
                              ? AppColors.primary
                              : AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),

                  // Skip button
                  TextButton(
                    onPressed: _skipOnboarding,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),

            //Navigation buttons
            Padding(
              padding: EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button
                  _currentPage > 0
                      ? TextButton.icon(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          icon: Icon(Icons.arrow_back_ios, size: 16),
                          label: Text("Previous"),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : const SizedBox(width: 85),

                  // Next / Get Started button
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 3,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentPage == _pages.length - 1
                              ? 'Get Started'
                              : 'Next',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _currentPage == _pages.length - 1
                              ? Icons.check
                              : Icons.arrow_forward_ios,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildPage(OnboardingPage page) {
  return Padding(
    padding: const EdgeInsets.all(30.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated icon
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 800),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: page.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: page.color.withOpacity(0.2),
                      blurRadius: 20,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: ClipOval(child: page.image),
              ),
            );
          },
        ),

        const SizedBox(height: 40),

        // Title
        Text(
          page.title,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
          textAlign: TextAlign.center,
        ),

        // Description
        Text(
          page.description,
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey.shade800,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

class OnboardingPage {
  final Image image;
  final String title;
  final String description;
  final Color color;

  OnboardingPage({
    required this.image,
    required this.title,
    required this.description,
    required this.color,
  });
}
