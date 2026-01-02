import 'package:flutter/material.dart';
import 'package:tutorix/core/widgets/custom_text_field.dart';
import 'package:tutorix/core/widgets/my_button.dart';
import 'login_page.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

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

              /// Title
              Column(
                children: const [
                  Text(
                    "Create Account",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Personal Information",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              /// Profile Image
              Column(
                children: [
                  const CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 55,
                      color: Colors.grey,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Pick image later
                    },
                    child: const Text(
                      "Upload your picture",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Name Fields
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

              const SizedBox(height: 12),

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

              const SizedBox(height: 10),

              /// Terms & Conditions
              Row(
                children: [
                  Checkbox(
                    value: true,
                    onChanged: (_) {},
                    activeColor: Colors.blue,
                  ),
                  const Expanded(
                    child: Text(
                      "I accept the terms and privacy policy",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Create Button
              MyButton(
                text: "Create",
                showArrow: true,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginPage(),
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
