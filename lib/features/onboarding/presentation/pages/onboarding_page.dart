import 'package:flutter/material.dart';
import 'package:tutorix/features/onboarding/presentation/pages/onboarding_page_one.dart';
import 'package:tutorix/features/onboarding/presentation/pages/onboarding_page_two.dart';
import 'package:tutorix/features/onboarding/presentation/pages/onboarding_page_three.dart';
import 'package:tutorix/features/welcome/presentation/pages/welcome_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();

  void _goToWelcome() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const WelcomePage(),
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCEEDD2),
      body: PageView(
        controller: _pageController,
        children: [
          OnboardingPageOne(
            onSkip: _goToWelcome,
            onNext: _nextPage,
          ),
          OnboardingPageTwo(
            onSkip: _goToWelcome,
            onNext: _nextPage,
          ),
          OnboardingPageThree(
            onSkip: _goToWelcome,
            onNext: _goToWelcome,
          ),
        ],
      ),
    );
  }
}
