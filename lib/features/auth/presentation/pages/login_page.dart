// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:tutorix/app/routes/app_routes.dart';
// import 'package:tutorix/features/auth/presentation/pages/register_page.dart';
// import 'package:tutorix/features/auth/presentation/state/auth_state.dart';
// import 'package:tutorix/features/dashboard/presentation/pages/bottom_screen_layout.dart';
// import 'package:tutorix/core/widgets/custom_text_field.dart';
// import 'package:tutorix/core/widgets/my_button.dart';
// import 'package:tutorix/features/auth/presentation/view_model/auth_viewmodel.dart';
// import 'package:tutorix/core/utils/snackbar_utils.dart';

// class LoginPage extends ConsumerStatefulWidget {
//   const LoginPage({super.key});

//   @override
//   ConsumerState<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends ConsumerState<LoginPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   /// Handle login button press
//   void _handleLogin() {
//     if (_formKey.currentState!.validate()) {
//       ref.read(authViewModelProvider.notifier).login(
//             // username: _emailController.text.trim(),
//              email: _emailController.text.trim(),
//             password: _passwordController.text.trim(),
//           );
//     }
//   }

//   void _navigateToSignup() {
//     AppRoutes.push(context, const RegisterPage());
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authViewModelProvider);
//     // final isLoading = authState.status == AuthStatus.loading;

//     /// Reactive listener for errors and navigation
//     ref.listen<AuthState>(authViewModelProvider, (previous, next) {
//       if (next.status == AuthStatus.error && next.errorMessage != null) {
//         SnackbarUtils.showError(context, next.errorMessage ?? 'Login Failed');
//       } else if (next.status == AuthStatus.authenticated) {
//         SnackbarUtils.showSuccess(context, 'Login Successful');
//         AppRoutes.pushReplacement(context, const BottomScreenLayout());
//       }
//     });

//     return Scaffold(
//       backgroundColor: const Color(0xFFD9F2D5),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: SingleChildScrollView(
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 40),

//                   /// Logo & Greeting
//                   Center(
//                     child: Column(
//                       children: [
//                         Image.asset(
//                           "assets/images/splashscreenlogo.png",
//                           width: 180,
//                         ),
//                         const Text(
//                           "Hello",
//                           style: TextStyle(
//                             fontSize: 60,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 5),

//                   const Center(
//                     child: Text(
//                       "Sign in to your Tutorix account",
//                       style: TextStyle(fontSize: 20),
//                     ),
//                   ),

//                   const SizedBox(height: 25),

//                   /// Email Field
//                   CustomTextField(
//                     hint: "E-mail",
//                     icon: Icons.email_outlined,
//                     controller: _emailController,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter your email';
//                       }
//                       if (!value.contains('@')) {
//                         return 'Please enter a valid email';
//                       }
//                       return null;
//                     },
//                   ),

//                   const SizedBox(height: 16),

//                   /// Password Field
//                   CustomTextField(
//                     hint: "Password",
//                     icon: Icons.lock_outline,
//                     obscure: true,
//                     controller: _passwordController,
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Please enter your password';
//                       }
//                       if (value.length < 6) {
//                         return 'Password must be at least 6 characters';
//                       }
//                       return null;
//                     },
//                   ),

//                   const SizedBox(height: 20),

//                    Align(
//                 alignment: Alignment.centerRight,
//                 child: Text(
//                   "Forgot your password?",
//                   style: TextStyle(
//                     color: Colors.black87,
//                     fontSize: 14,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 50),

//                   /// Sign In Button
//                   MyButton(
//                   //   text: isLoading ? 'Signing in...' : "Sign in",
//                   //   showArrow: true,
//                   //   onPressed: isLoading ? null : _handleLogin,
//                   // ),
//                    text: "Sign in",
//   isLoading: authState.status == AuthStatus.loading,
//   onPressed: authState.status == AuthStatus.loading ? null : _handleLogin,
// ),

//                   const SizedBox(height: 30),

//                   /// Google Sign-in
//                   Container(
//                     height: 55,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Image.asset("assets/images/google.png", height: 24),
//                         const SizedBox(width: 12),
//                         const Text(
//                           "Sign in with Google",
//                           style: TextStyle(fontSize: 20),
//                         ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 15),

//                   /// Register Link
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text("Don’t have an account?", style: TextStyle(color: Colors.black, fontSize: 16),),
//                       TextButton(
//                         onPressed: _navigateToSignup,
//                         child: const Text("Create Account",style: TextStyle(
//                         color: Colors.blue,
//                         fontSize: 16,
//                         decoration: TextDecoration.underline,),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/app/routes/app_routes.dart';
import 'package:tutorix/features/auth/presentation/pages/register_page.dart';
import 'package:tutorix/features/auth/presentation/state/auth_state.dart';
import 'package:tutorix/features/dashboard/presentation/pages/bottom_screen_layout.dart';
import 'package:tutorix/core/widgets/custom_text_field.dart';
import 'package:tutorix/core/widgets/my_button.dart';
import 'package:tutorix/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:tutorix/core/utils/snackbar_utils.dart';
import 'dart:io';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      ref.read(authViewModelProvider.notifier).login(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
    }
  }

  void _navigateToSignup() {
    AppRoutes.push(context, const RegisterPage());
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    // Listen to auth state changes
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage ?? 'Login Failed');
      } else if (next.status == AuthStatus.authenticated) {
        SnackbarUtils.showSuccess(context, 'Login Successful');
        AppRoutes.pushReplacement(context, const BottomScreenLayout());
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFD9F2D5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Column(
                      children: [
                        Image.asset("assets/images/splashscreenlogo.png", width: 180),
                        const Text(
                          "Hello",
                          style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Center(
                    child: Text(
                      "Sign in to your Tutorix account",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: 25),

                  CustomTextField(
                    hint: "E-mail",
                    icon: Icons.email_outlined,
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your email';
                      if (!value.contains('@')) return 'Please enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    hint: "Password",
                    icon: Icons.lock_outline,
                    obscure: true,
                    controller: _passwordController,

                    suffixIcon: IconButton(
                    icon: Icon(
                        _showPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                  ),

                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Please enter your password';
                      if (value.length < 6) return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Forgot your password?",
                      style: TextStyle(color: Colors.black87, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 50),

                  MyButton(
                    text: "Sign in",
                    isLoading: authState.status == AuthStatus.loading,
                    onPressed: authState.status == AuthStatus.loading ? null : _handleLogin,
                  ),
                  const SizedBox(height: 30),

                  // Google sign-in
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
                        const Text("Sign in with Google", style: TextStyle(fontSize: 20)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don’t have an account?", style: TextStyle(color: Colors.black, fontSize: 16)),
                      TextButton(
                        onPressed: _navigateToSignup,
                        child: const Text(
                          "Create Account",
                          style: TextStyle(color: Colors.blue, fontSize: 16, decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


