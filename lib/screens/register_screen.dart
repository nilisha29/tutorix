import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/my_button.dart';
import 'login_screen.dart';   // ← ADD THIS IMPORT

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9F2D5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [

              const SizedBox(height: 20),

              // TITLE
              Center(
                child: Column(
                  children: [
                    const Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Personal Information",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // PROFILE IMAGE
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 55, color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Upload your picture",
                        style: TextStyle(color: Colors.black),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // FIRST & LAST NAME
              Row(
                children: const [
                  Expanded(
                    child: CustomTextField(
                      hint: "First name",
                      icon: Icons.person_outline,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      hint: "Last name",
                      icon: Icons.person_outline,
                    ),
                  ),
                ],
              ),

              const CustomTextField(
                hint: "E-mail",
                icon: Icons.email_outlined,
              ),
              const CustomTextField(
                hint: "Password",
                icon: Icons.lock_outline,
                obscure: true,
              ),
              const CustomTextField(
                hint: "Phone Number",
                icon: Icons.phone,
              ),
              const CustomTextField(
                hint: "Age",
                icon: Icons.calendar_month,
              ),
              const CustomTextField(
                hint: "Address",
                icon: Icons.location_on_outlined,
              ),

              const SizedBox(height: 8),

              // TERMS CHECKBOX
              Row(
                children: [
                  Checkbox(
                    value: true,
                    onChanged: (_) {},
                    side: const BorderSide(color: Colors.white),
                    checkColor: Colors.white,
                    activeColor: Colors.blue,
                  ),
                  const Expanded(
                    child: Text(
                      "I accept the terms and privacy policy",
                      style: TextStyle(color: Colors.black),
                    ),
                  )
                ],
              ),

              const SizedBox(height: 20),

              // CREATE BUTTON → GO TO LOGIN SCREEN
              MyButton(
                text: "Create",
                showArrow: true,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}


