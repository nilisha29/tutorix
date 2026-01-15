import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/features/auth/presentation/pages/register_page.dart';
import 'package:tutorix/features/auth/presentation/state/auth_state.dart';
import 'package:tutorix/features/dashboard/presentation/pages/bottom_screen_layout.dart';
import 'package:tutorix/core/widgets/custom_text_field.dart';
import 'package:tutorix/core/widgets/my_button.dart';
import 'package:tutorix/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:tutorix/core/utils/snackbar_utils.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9F2D5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
              const SizedBox(height: 40),

              /// Logo & Greeting
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

              /// Email & Password
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

              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Forgot your password?",
                  style: TextStyle(color: Colors.black87, fontSize: 14),
                ),
              ),

              const SizedBox(height: 50),

              /// Sign In Button
              MyButton(
                text: _isLoading ? 'Signing in...' : "Sign in",
                showArrow: true,
                onPressed: _isLoading
                    ? null
                    : () async {
                        final email = _emailController.text.trim();
                        final password = _passwordController.text;

                        if (email.isEmpty || password.isEmpty) {
                          SnackbarUtils.showError(context, 'Please enter email and password');
                          return;
                        }

                        setState(() => _isLoading = true);
                        await ref.read(authViewmodelProvider.notifier).login(
                              email: email,
                              password: password,
                            );

                        final state = ref.read(authViewmodelProvider);
                        setState(() => _isLoading = false);

                        if (state.status == AuthStatus.authenticated) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BottomScreenLayout(),
                            ),
                          );
                        } else {
                          SnackbarUtils.showError(context, state.errorMessage ?? 'Invalid credentials');
                        }
                      },
              ),

              const SizedBox(height: 30),

              /// Sign In with Google
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

              /// Register Redirect
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
                          builder: (_) => const RegisterPage(),
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
              );
            },
          ),
        ),
      ),
    );
  }
}

