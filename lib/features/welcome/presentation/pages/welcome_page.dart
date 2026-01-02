import 'package:flutter/material.dart';
import 'package:tutorix/features/auth/presentation/pages/login_page.dart';
import 'package:tutorix/features/auth/presentation/pages/register_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD8F2D8),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),

            /// Logo
            Image.asset(
              "assets/images/splashscreenlogo.png",
              height: 300,
              width: 500,
            ),

            const SizedBox(height: 10),

            /// Sign In Button
            _buildButton(
              context: context,
              text: "Sign in",
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              ),
            ),

            const SizedBox(height: 25),

            /// Register Button
            _buildButton(
              context: context,
              text: "Register",
              icon: Icons.arrow_drop_down,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterPage()),
              ),
            ),

            const SizedBox(height: 80),

            /// Terms & Conditions
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text.rich(
                TextSpan(
                  text: "By creating an account or signing you\nagree to our ",
                  style: TextStyle(color: Colors.black87, fontSize: 20),
                  children: [
                    TextSpan(
                      text: "Terms and Conditions",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// Reusable Button
  Widget _buildButton({
    required BuildContext context,
    required String text,
    IconData? icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
      ),
      padding: const EdgeInsets.all(4),
      margin: const EdgeInsets.symmetric(horizontal: 60),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3F6B4F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(35),
            ),
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
              if (icon != null) ...[
                const SizedBox(width: 6),
                Icon(icon, color: Colors.white),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

