import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/my_button.dart';
import 'home_screen.dart';          
import 'register_screen.dart';    

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9F2D5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 40),

              Center(
                child: Column(
                  children: [
                    Image.asset(
                      "assets/images/splashscreenlogo.png",
                      width: 180,
                    ),
                    const Text(
                      "Hello",
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 5),

              const Center(
                child: Text(
                  "Sign in to your Tutorix account",
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
              ),

              const SizedBox(height: 25),

              // Email
              const CustomTextField(
                hint: "E-mail",
                icon: Icons.email_outlined,
              ),

              // Password
              const CustomTextField(
                hint: "Password",
                icon: Icons.lock_outline,
                obscure: true,
              ),

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Forgot your password?",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 50),

             
              MyButton(
                text: "Sign in",
                showArrow: true,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                },
              ),

              const SizedBox(height: 30),

            
              Container(
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/images/google.png", height: 24),
                    const SizedBox(width: 12),
                    const Text(
                      "Sign in with Google",
                      style: TextStyle(fontSize: 20),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

             
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don’t have an account?",
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Create Account",
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}


