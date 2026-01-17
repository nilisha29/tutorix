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
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_agreedToTerms) {
      SnackbarUtils.showError(context, 'Please agree to the Terms & Conditions');
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      await ref.read(authViewModelProvider.notifier).register(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            username: _emailController.text.split('@').first,
            password: _passwordController.text,
            phoneNumber:
                _phoneController.text.isNotEmpty ? _phoneController.text : null,
          );

      final state = ref.read(authViewModelProvider);
      setState(() => _isLoading = false);

      if (state.status == AuthStatus.registered) {
        SnackbarUtils.showSuccess(context, 'Registration Successful');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      } else if (state.status == AuthStatus.error) {
        SnackbarUtils.showError(
            context, state.errorMessage ?? 'Registration failed');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFD9F2D5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
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
                      onPressed: () {},
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
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        hint: "Last name",
                        icon: Icons.person_outline,
                        controller: _lastNameController,
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
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
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    if (!v.contains('@')) return 'Invalid email';
                    return null;
                  },
                ),
                CustomTextField(
                  hint: "Password",
                  icon: Icons.lock_outline,
                  obscure: true,
                  controller: _passwordController,
                  validator: (v) =>
                      v == null || v.length < 6 ? 'Min 6 chars' : null,
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
                      value: _agreedToTerms,
                      onChanged: (val) {
                        setState(() => _agreedToTerms = val ?? false);
                      },
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
                 isLoading: authState.status == AuthStatus.loading,
  onPressed: authState.status == AuthStatus.loading ? null : _handleSignup,
),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

