import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/widgets/custom_text_field.dart';
import 'package:tutorix/core/widgets/my_button.dart';
import 'package:tutorix/features/auth/presentation/state/auth_state.dart';
import 'package:tutorix/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:tutorix/core/utils/snackbar_utils.dart';
import 'login_page.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

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
                children: [
                  Expanded(
                    child: CustomTextField(
                      hint: "First name",
                      icon: Icons.person_outline,
                      controller: _firstNameController,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      hint: "Last name",
                      icon: Icons.person_outline,
                      controller: _lastNameController,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              CustomTextField(
                hint: "E-mail",
                icon: Icons.email_outlined,
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
              ),
              CustomTextField(
                hint: "Password",
                icon: Icons.lock_outline,
                obscure: true,
                controller: _passwordController,
              ),
              CustomTextField(
                hint: "Phone Number",
                icon: Icons.phone,
                controller: _phoneController,
                keyboardType: TextInputType.phone,
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
                text: _isLoading ? "Creating..." : "Create",
                showArrow: true,
                onPressed: _isLoading
                    ? null
                    : () async {
                        final fullName = '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'.trim();
                        final email = _emailController.text.trim();
                        final password = _passwordController.text;
                        final phone = _phoneController.text.trim();

                        if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
                          SnackbarUtils.showError(context, 'Please fill required fields');
                          return;
                        }

                        setState(() => _isLoading = true);
                        await ref.read(authViewmodelProvider.notifier).register(
                              fullName: fullName,
                              email: email,
                              phoneNumber: phone.isEmpty ? null : phone,
                              username: email.split('@').first,
                              password: password,
                            );

                        final state = ref.read(authViewmodelProvider);
                        setState(() => _isLoading = false);

                        if (state.status == AuthStatus.registered) {
                          SnackbarUtils.showSuccess(context, 'Registered successfully');
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginPage()),
                          );
                        } else {
                          SnackbarUtils.showError(context, state.errorMessage ?? 'Registration failed');
                        }
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
