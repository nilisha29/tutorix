import 'package:flutter/material.dart';

class OnboardingPageOne extends StatelessWidget {
  final VoidCallback onSkip;
  final VoidCallback onNext;

  const OnboardingPageOne({
    super.key,
    required this.onSkip,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCEEDD2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Skip Button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onSkip,
                  child: const Text(
                    "Skip",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              /// Title
              const Text(
                "Welcome",
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),

              const SizedBox(height: 10),

              /// Subtitle
              const Text(
                "Connecting you to the\nperfect tutor, anytime.",
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 40),

              /// Image
              Center(
                child: Image.asset(
                  'assets/images/on1.png',
                  height: 300,
                ),
              ),

              const Spacer(),

              /// Next Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onNext,
                  child: const Text(
                    "Let’s get started",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 60),

              /// Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _Dot(active: true),
                  _Dot(active: false),
                  _Dot(active: false),
                ],
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dot Indicator Widget
class _Dot extends StatelessWidget {
  final bool active;

  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      width: active ? 25 : 10,
      height: 10,
      decoration: BoxDecoration(
        color: active ? Colors.green : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
