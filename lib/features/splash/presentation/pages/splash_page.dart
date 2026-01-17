import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/services/storage/user_session_service.dart';
import 'package:tutorix/features/dashboard/presentation/pages/home_page.dart';
import 'package:tutorix/features/onboarding/presentation/pages/onboarding_page.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateToOnboarding();
  }

  void _navigateToOnboarding() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      //check if the widget is still mounted
      final UserSessionService = ref.read(userSessionServiceProvider);
      final isLoggedIn = UserSessionService.isLoggedIn();

      if (isLoggedIn) {
        // User is logged in → Go to home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomePage(),
          ),
        );
      } else {
        // User not logged in → Go to onboarding/login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const OnboardingPage(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCEEDD2),
      body: Center(
        child: Image.asset(
          'assets/images/splashscreenlogo.png',
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}
