import 'package:flutter/material.dart';

class OnboardingPageTwo extends StatelessWidget {
  final VoidCallback onSkip;
  final VoidCallback onNext;

  const OnboardingPageTwo({
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
                'assets/images/on2.png',
                height: 250,
                width: 250,
              ),

              const SizedBox(height: 30),

              /// Title
              const Text(
                "Where better learning\nbegins at home",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 20),

              /// Subtitle
              const Text(
                "Making tutoring simple\nand accessible",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.green,
                ),
              ),

              const Spacer(),

              /// Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _Dot(active: false),
                  _Dot(active: true),
                  _Dot(active: false),
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
