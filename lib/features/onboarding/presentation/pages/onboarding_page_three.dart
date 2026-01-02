import 'package:flutter/material.dart';

class OnboardingPageThree extends StatelessWidget {
  final VoidCallback onSkip;
  final VoidCallback onNext;

  const OnboardingPageThree({
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

              const SizedBox(height: 20),

              /// Image
              Image.asset(
                'assets/images/on3.png',
                height: 250,
              ),

              const SizedBox(height: 30),

              /// Title
              const Text(
                "Easy Booking &\nSecure Payments",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 12),

              /// Subtitle
              const Text(
                "Effortlessly schedule sessions and\nmake payments securely through our\nintegrated system, all within the app.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 100),

              /// Continue Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onNext,
                  child: const Text(
                    "Continue",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),

              const Spacer(),

              /// Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _Dot(active: false),
                  _Dot(active: false),
                  _Dot(active: true),
                ],
              ),

              const SizedBox(height: 50),
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
