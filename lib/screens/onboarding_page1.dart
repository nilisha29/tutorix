import 'package:flutter/material.dart';

class OnboardingPage1 extends StatelessWidget {
  final VoidCallback onSkip;
  final VoidCallback onNext;

  const OnboardingPage1({
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
             
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onSkip,
                  child: const Text(
                    "Skip",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 10),

            
              const Text(
                "Welcome",
                style: TextStyle(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Connecting you to the\nperfect tutor, anytime.",
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 40),

         
              Center(
                child: Image.asset(
                  'assets/images/on1.png',
                  height: 300,
                ),
              ),

              const Spacer(),

            
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: onNext,
                  child: const Text(
                    "Lets get started",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 100),

             
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _dot(true),
                  _dot(false),
                  _dot(false),
                ],
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(bool active) {
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









