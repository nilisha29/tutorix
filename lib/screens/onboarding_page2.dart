import 'package:flutter/material.dart';

class OnboardingPage2 extends StatelessWidget {
  final VoidCallback onSkip;
  final VoidCallback onNext; 

  const OnboardingPage2({
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

              const SizedBox(height: 20),

             
              Image.asset(
                'assets/images/on2.png',
                height: 250,
                width: 250,
              ),

              const SizedBox(height: 30),

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

              const Text(
                "Making tutoring simple\nand accessible",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: Colors.green),
              ),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _dot(false),
                  _dot(true),
                  _dot(false),
                ],
              ),

              const SizedBox(height: 50),
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









