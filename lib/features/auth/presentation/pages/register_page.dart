// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:tutorix/core/widgets/custom_text_field.dart';
// import 'package:tutorix/core/widgets/my_button.dart';
// import 'package:tutorix/features/auth/presentation/state/auth_state.dart';
// import 'package:tutorix/features/auth/presentation/view_model/auth_viewmodel.dart';
// import 'package:tutorix/core/utils/snackbar_utils.dart';
// import 'login_page.dart';

// class RegisterPage extends ConsumerStatefulWidget {
//   const RegisterPage({super.key});

//   @override
//   ConsumerState<RegisterPage> createState() => _RegisterPageState();
// }

// class _RegisterPageState extends ConsumerState<RegisterPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _firstNameController = TextEditingController();
//   final _lastNameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _phoneController = TextEditingController();

//   bool _isLoading = false;
//   bool _obscurePassword = true;
//   bool _agreedToTerms = false;

//   @override
//   void dispose() {
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _phoneController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleSignup() async {
//     if (!_agreedToTerms) {
//       SnackbarUtils.showError(context, 'Please agree to the Terms & Conditions');
//       return;
//     }

//     if (_formKey.currentState!.validate()) {
//       setState(() => _isLoading = true);

//       await ref.read(authViewModelProvider.notifier).register(
//             firstName: _firstNameController.text.trim(),
//             lastName: _lastNameController.text.trim(),
//             email: _emailController.text.trim(),
//             username: _emailController.text.split('@').first,
//             password: _passwordController.text,
//             phoneNumber:
//                 _phoneController.text.isNotEmpty ? _phoneController.text : null,
//           );

//       final state = ref.read(authViewModelProvider);
//       setState(() => _isLoading = false);

//       if (state.status == AuthStatus.registered) {
//         SnackbarUtils.showSuccess(context, 'Registration Successful');
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const LoginPage()),
//         );
//       } else if (state.status == AuthStatus.error) {
//         SnackbarUtils.showError(
//             context, state.errorMessage ?? 'Registration failed');
//       }
//     }
//   }


//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authViewModelProvider);

//     return Scaffold(
//       backgroundColor: const Color(0xFFD9F2D5),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 const SizedBox(height: 20),

//                 /// Title
//                 Column(
//                   children: const [
//                     Text(
//                       "Create Account",
//                       style: TextStyle(
//                         fontSize: 32,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     ),
//                     SizedBox(height: 6),
//                     Text(
//                       "Personal Information",
//                       style: TextStyle(
//                         fontSize: 15,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 25),

//                 /// Profile Image
//                 Column(
//                   children: [
//                     const CircleAvatar(
//                       radius: 45,
//                       backgroundColor: Colors.white,
//                       child: Icon(
//                         Icons.person,
//                         size: 55,
//                         color: Colors.grey,
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: () {},
//                       child: const Text(
//                         "Upload your picture",
//                         style: TextStyle(color: Colors.black),
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 20),

//                 /// Name Fields
//                 Row(
//                   children: [
//                     Expanded(
//                       child: CustomTextField(
//                         hint: "First name",
//                         icon: Icons.person_outline,
//                         controller: _firstNameController,
//                         validator: (v) =>
//                             v == null || v.isEmpty ? 'Required' : null,
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: CustomTextField(
//                         hint: "Last name",
//                         icon: Icons.person_outline,
//                         controller: _lastNameController,
//                         validator: (v) =>
//                             v == null || v.isEmpty ? 'Required' : null,
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 12),

//                 CustomTextField(
//                   hint: "E-mail",
//                   icon: Icons.email_outlined,
//                   controller: _emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (v) {
//                     if (v == null || v.isEmpty) return 'Required';
//                     if (!v.contains('@')) return 'Invalid email';
//                     return null;
//                   },
//                 ),
//                 CustomTextField(
//                   hint: "Password",
//                   icon: Icons.lock_outline,
//                   obscure: true,
//                   controller: _passwordController,
//                   validator: (v) =>
//                       v == null || v.length < 6 ? 'Min 6 chars' : null,
//                 ),
//                 CustomTextField(
//                   hint: "Phone Number",
//                   icon: Icons.phone,
//                   controller: _phoneController,
//                   keyboardType: TextInputType.phone,
//                 ),

//                 const SizedBox(height: 10),

//                 CustomTextField(
//                 hint: "Age",
//                 icon: Icons.calendar_month,
//               ),
//               const SizedBox(height: 8),

//               CustomTextField(
//                 hint: "Address",
//                 icon: Icons.location_on_outlined,
//               ),

//               const SizedBox(height: 8),


//                 /// Terms & Conditions
//                 Row(
//                   children: [
//                     Checkbox(
//                       value: _agreedToTerms,
//                       onChanged: (val) {
//                         setState(() => _agreedToTerms = val ?? false);
//                       },
//                       activeColor: Colors.blue,
//                     ),
//                     const Expanded(
//                       child: Text(
//                         "I accept the terms and privacy policy",
//                         style: TextStyle(color: Colors.black),
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 20),

//                 /// Create Button
//                 MyButton(
//                   text: "Create",
//                  isLoading: authState.status == AuthStatus.loading,
//   onPressed: authState.status == AuthStatus.loading ? null : _handleSignup,
// ),

//                 const SizedBox(height: 30),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:tutorix/core/widgets/custom_text_field.dart';
// import 'package:tutorix/core/widgets/my_button.dart';
// import 'package:tutorix/features/auth/presentation/state/auth_state.dart';
// import 'package:tutorix/features/auth/presentation/view_model/auth_viewmodel.dart';
// import 'package:tutorix/core/utils/snackbar_utils.dart';
// import 'login_page.dart';

// class RegisterPage extends ConsumerStatefulWidget {
//   const RegisterPage({super.key});

//   @override
//   ConsumerState<RegisterPage> createState() => _RegisterPageState();
// }

// class _RegisterPageState extends ConsumerState<RegisterPage> {
//   final _formKey = GlobalKey<FormState>();

//   final _fullNameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _addressController = TextEditingController();

//   bool _agreedToTerms = false;
//   bool _showPassword = false;
// bool _showConfirmPassword = false;

//   @override
//   void dispose() {
//     _fullNameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     _phoneController.dispose();
//     _addressController.dispose();
//     super.dispose();
//   }

//   Future<void> _handleSignup() async {
//     if (!_agreedToTerms) {
//       SnackbarUtils.showError(
//           context, 'Please agree to the Terms & Conditions');
//       return;
//     }

//     if (_formKey.currentState!.validate()) {
//        final fullName = _fullNameController.text.trim();
//     final username = _emailController.text.split('@').first;
//       await ref.read(authViewModelProvider.notifier).register(
//             // firstName: _fullNameController.text.trim(),
//             // lastName: "", // kept empty intentionally
//              fullName: fullName,
//           username: username,
//             email: _emailController.text.trim(),
//             // username: _emailController.text.split('@').first,
//             password: _passwordController.text,
//             confirmPassword: _confirmPasswordController.text,
//             phoneNumber:
//                 _phoneController.text.isNotEmpty ? _phoneController.text : null,
//                  profilePicture: null, 
//                  address: _addressController.text.isNotEmpty ? _addressController.text : null,
              
//           );

//       final state = ref.read(authViewModelProvider);

//       if (state.status == AuthStatus.registered) {
//         SnackbarUtils.showSuccess(context, 'Registration Successful');
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const LoginPage()),
//         );
//       } else if (state.status == AuthStatus.error) {
//         SnackbarUtils.showError(
//             context, state.errorMessage ?? 'Registration failed');
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authViewModelProvider);

//     return Scaffold(
//       backgroundColor: const Color(0xFFD9F2D5),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 const SizedBox(height: 20),

//                 /// Title
//                 const Column(
//                   children: [
//                     Text(
//                       "Create Account",
//                       style: TextStyle(
//                         fontSize: 32,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(height: 6),
//                     Text(
//                       "Sign up to continue",
//                       style: TextStyle(fontSize: 15),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 25),

//                 /// Profile Image (Optional)
//                 Column(
//                   children: [
//                     const CircleAvatar(
//                       radius: 45,
//                       backgroundColor: Colors.white,
//                       child: Icon(
//                         Icons.person,
//                         size: 55,
//                         color: Colors.grey,
//                       ),
//                     ),
//                     TextButton(
//                       onPressed: () {},
//                       child: const Text("Upload your picture"),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 20),

//                 /// Full Name
//                 CustomTextField(
//                   hint: "Full Name",
//                   icon: Icons.person_outline,
//                   controller: _fullNameController,
//                   validator: (v) =>
//                       v == null || v.isEmpty ? 'Required' : null,
//                 ),

//                 const SizedBox(height: 12),

//                 /// Email
//                 CustomTextField(
//                   hint: "E-mail",
//                   icon: Icons.email_outlined,
//                   controller: _emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (v) {
//                     if (v == null || v.isEmpty) return 'Required';
//                     if (!v.contains('@')) return 'Invalid email';
//                     return null;
//                   },
//                 ),

//                 const SizedBox(height: 12),

//                 /// Password
//                 CustomTextField(
//                   hint: "Password",
//                   icon: Icons.lock_outline,
//                   // obscure: true,
//                     obscure: !_showPassword,
//                   controller: _passwordController,
//                   suffixIcon: IconButton(
//     icon: Icon(
//       _showPassword ? Icons.visibility : Icons.visibility_off,
//     ),
//     onPressed: () {
//       setState(() => _showPassword = !_showPassword);
//     },
//   ),
//                   validator: (v) =>
//                       v == null || v.length < 6 ? 'Min 6 characters' : null,
//                 ),

//                 const SizedBox(height: 12),

//                 /// Confirm Password
//                 CustomTextField(
//                   hint: "Confirm Password",
//                   icon: Icons.lock_outline,
//                   // obscure: true,
//                    obscure: !_showConfirmPassword,
//                   controller: _confirmPasswordController,
//                   suffixIcon: IconButton(
//     icon: Icon(
//       _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
//     ),
//     onPressed: () {
//       setState(() =>
//           _showConfirmPassword = !_showConfirmPassword);
//     },
//   ),
//                   validator: (v) {
//                     if (v == null || v.isEmpty) return 'Required';
//                     if (v != _passwordController.text) {
//                       return 'Passwords do not match';
//                     }
//                     return null;
//                   },
//                 ),

//                 const SizedBox(height: 12),

//                 /// Phone Number
//                 CustomTextField(
//                   hint: "Phone Number",
//                   icon: Icons.phone,
//                   controller: _phoneController,
//                   keyboardType: TextInputType.phone,
//                 ),

//                 const SizedBox(height: 12),

//                 /// Address
//                 CustomTextField(
//                   hint: "Address",
//                   icon: Icons.location_on_outlined,
//                   controller: _addressController,
//                 ),

//                 const SizedBox(height: 12),

//                 /// Terms & Conditions
//                 Row(
//                   children: [
//                     Checkbox(
//                       value: _agreedToTerms,
//                       onChanged: (val) {
//                         setState(() => _agreedToTerms = val ?? false);
//                       },
//                     ),
//                     const Expanded(
//                       child: Text(
//                         "I accept the terms and privacy policy",
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 20),

//                 /// Create Button
//                 MyButton(
//                   text: "Create Account",
//                   isLoading: authState.status == AuthStatus.loading,
//                   onPressed: authState.status == AuthStatus.loading
//                       ? null
//                       : _handleSignup,
//                 ),

//                 const SizedBox(height: 20),

//                 /// Already have an account
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text("Already have an account?"),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                               builder: (_) => const LoginPage()),
//                         );
//                       },
//                       child: const Text("Sign in"),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }





// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:tutorix/core/widgets/custom_text_field.dart';
// import 'package:tutorix/core/widgets/my_button.dart';
// import 'package:tutorix/core/utils/snackbar_utils.dart';
// import 'package:tutorix/features/auth/presentation/state/auth_state.dart';
// import 'package:tutorix/features/auth/presentation/view_model/auth_viewmodel.dart';
// import 'login_page.dart';

// class RegisterPage extends ConsumerStatefulWidget {
//   const RegisterPage({super.key});

//   @override
//   ConsumerState<RegisterPage> createState() => _RegisterPageState();
// }

// class _RegisterPageState extends ConsumerState<RegisterPage> {
//   final _formKey = GlobalKey<FormState>();

//   // Controllers
//   final _fullNameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _addressController = TextEditingController();

//   // UI state
//   bool _agreedToTerms = false;
//   bool _showPassword = false;
//   bool _showConfirmPassword = false;

//   @override
//   void dispose() {
//     _fullNameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     _phoneController.dispose();
//     _addressController.dispose();
//     super.dispose();
//   }

//   /// Pick profile image from camera or gallery
//   Future<void> _pickProfileImage(bool fromCamera) async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(
//       source: fromCamera ? ImageSource.camera : ImageSource.gallery,
//       imageQuality: 70,
//     );

//     if (pickedFile != null) {
//       // Update state in AuthViewModel
//       ref.read(authViewModelProvider.notifier).setProfilePicture(pickedFile.path);
//     }
//   }

//   /// Handle registration/signup
//   Future<void> _handleSignup() async {
//     if (!_agreedToTerms) {
//       SnackbarUtils.showError(context, 'Please accept Terms & Conditions');
//       return;
//     }

//     final profilePath = ref.read(authViewModelProvider).profilePicture;
//     if (profilePath == null) {
//       SnackbarUtils.showError(context, 'Please upload profile picture');
//       return;
//     }

//     if (!_formKey.currentState!.validate()) return;

//     final fullName = _fullNameController.text.trim();
//     final email = _emailController.text.trim();
//     final username = email.split('@').first;

//     // Call register function in ViewModel
//     await ref.read(authViewModelProvider.notifier).register(
//           fullName: fullName,
//           username: username,
//           email: email,
//           password: _passwordController.text,
//           confirmPassword: _confirmPasswordController.text,
//           phoneNumber:
//               _phoneController.text.isNotEmpty ? _phoneController.text : null,
//           address:
//               _addressController.text.isNotEmpty ? _addressController.text : null,
//           profilePicture: profilePath,
//         );

//     final state = ref.read(authViewModelProvider);

//     if (state.status == AuthStatus.registered) {
//       SnackbarUtils.showSuccess(context, 'Registration Successful');
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const LoginPage()),
//       );
//     } else if (state.status == AuthStatus.error) {
//       SnackbarUtils.showError(
//         context,
//         state.errorMessage ?? 'Registration Failed',
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authViewModelProvider);
//     final profilePath = authState.profilePicture;

//     return Scaffold(
//       backgroundColor: const Color(0xFFD9F2D5),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 const SizedBox(height: 20),

//                 // Title
//                 const Text(
//                   "Create Account",
//                   style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 6),
//                 const Text("Sign up to continue"),
//                 const SizedBox(height: 25),

//                 // Profile Image Picker
//                 Column(
//                   children: [
//                     CircleAvatar(
//                       radius: 45,
//                       backgroundColor: Colors.white,
//                       backgroundImage:
//                           profilePath != null ? FileImage(File(profilePath)) : null,
//                       child: profilePath == null
//                           ? const Icon(Icons.person, size: 55, color: Colors.grey)
//                           : null,
//                     ),
//                     TextButton(
//                       child: const Text("Upload your picture"),
//                       onPressed: () {
//                         showModalBottomSheet(
//                           context: context,
//                           builder: (_) => Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               ListTile(
//                                 leading: const Icon(Icons.camera),
//                                 title: const Text('Take Photo'),
//                                 onTap: () {
//                                   Navigator.pop(context);
//                                   _pickProfileImage(true);
//                                 },
//                               ),
//                               ListTile(
//                                 leading: const Icon(Icons.photo_library),
//                                 title: const Text('Choose from Gallery'),
//                                 onTap: () {
//                                   Navigator.pop(context);
//                                   _pickProfileImage(false);
//                                 },
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 20),

//                 // Full Name
//                 CustomTextField(
//                   hint: "Full Name",
//                   icon: Icons.person_outline,
//                   controller: _fullNameController,
//                   validator: (v) => v == null || v.isEmpty ? 'Required' : null,
//                 ),
//                 const SizedBox(height: 12),

//                 // Email
//                 CustomTextField(
//                   hint: "E-mail",
//                   icon: Icons.email_outlined,
//                   controller: _emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (v) =>
//                       v == null || !v.contains('@') ? 'Invalid email' : null,
//                 ),
//                 const SizedBox(height: 12),

//                 // Password
//                 CustomTextField(
//                   hint: "Password",
//                   icon: Icons.lock_outline,
//                   obscure: !_showPassword,
//                   controller: _passwordController,
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                         _showPassword ? Icons.visibility : Icons.visibility_off),
//                     onPressed: () =>
//                         setState(() => _showPassword = !_showPassword),
//                   ),
//                   validator: (v) =>
//                       v == null || v.length < 6 ? 'Min 6 characters' : null,
//                 ),
//                 const SizedBox(height: 12),

//                 // Confirm Password
//                 CustomTextField(
//                   hint: "Confirm Password",
//                   icon: Icons.lock_outline,
//                   obscure: !_showConfirmPassword,
//                   controller: _confirmPasswordController,
//                   suffixIcon: IconButton(
//                     icon: Icon(_showConfirmPassword
//                         ? Icons.visibility
//                         : Icons.visibility_off),
//                     onPressed: () =>
//                         setState(() => _showConfirmPassword = !_showConfirmPassword),
//                   ),
//                   validator: (v) =>
//                       v != _passwordController.text ? 'Passwords do not match' : null,
//                 ),
//                 const SizedBox(height: 12),

//                 // Phone Number
//                 CustomTextField(
//                   hint: "Phone Number",
//                   icon: Icons.phone,
//                   controller: _phoneController,
//                 ),
//                 const SizedBox(height: 12),

//                 // Address
//                 CustomTextField(
//                   hint: "Address",
//                   icon: Icons.location_on_outlined,
//                   controller: _addressController,
//                 ),
//                 const SizedBox(height: 12),

//                 // Terms & Conditions
//                 Row(
//                   children: [
//                     Checkbox(
//                       value: _agreedToTerms,
//                       onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
//                     ),
//                     const Expanded(
//                       child: Text("I accept the terms and privacy policy"),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 20),

//                 // Register Button
//                 MyButton(
//                   text: "Create Account",
//                   isLoading: authState.status == AuthStatus.loading,
//                   onPressed:
//                       authState.status == AuthStatus.loading ? null : _handleSignup,
//                 ),

//                 const SizedBox(height: 20),

//                 // Login redirect
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text("Already have an account?"),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(builder: (_) => const LoginPage()),
//                         );
//                       },
//                       child: const Text("Sign in"),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:tutorix/core/widgets/custom_text_field.dart';
// import 'package:tutorix/core/widgets/my_button.dart';
// import 'package:tutorix/core/utils/snackbar_utils.dart';
// import 'package:tutorix/features/auth/presentation/state/auth_state.dart';
// import 'package:tutorix/features/auth/presentation/view_model/auth_viewmodel.dart';
// import 'login_page.dart';

// class RegisterPage extends ConsumerStatefulWidget {
//   const RegisterPage({super.key});

//   @override
//   ConsumerState<RegisterPage> createState() => _RegisterPageState();
// }

// class _RegisterPageState extends ConsumerState<RegisterPage> {
//   final _formKey = GlobalKey<FormState>();

//   final _fullNameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _addressController = TextEditingController();

//   bool _agreedToTerms = false;
//   bool _showPassword = false;
//   bool _showConfirmPassword = false;

//   @override
//   void dispose() {
//     _fullNameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     _phoneController.dispose();
//     _addressController.dispose();
//     super.dispose();
//   }

//   /// Pick profile image
//   Future<void> _pickProfileImage(bool fromCamera) async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(
//       source: fromCamera ? ImageSource.camera : ImageSource.gallery,
//       imageQuality: 70,
//     );

//     if (pickedFile != null) {
//       ref
//           .read(authViewModelProvider.notifier)
//           .setProfilePicture(pickedFile.path);
//     }
//   }

//   /// Handle signup
//   Future<void> _handleSignup() async {
//     if (!_agreedToTerms) {
//       SnackbarUtils.showError(context, 'Please accept Terms & Conditions');
//       return;
//     }

//     if (!_formKey.currentState!.validate()) return;

//     final authState = ref.read(authViewModelProvider);
//     final profilePath = authState.profilePicture;

//     final email = _emailController.text.trim();

//     await ref.read(authViewModelProvider.notifier).register(
//           fullName: _fullNameController.text.trim(),
//           username: email.split('@').first,
//           email: email,
//           password: _passwordController.text,
//           confirmPassword: _confirmPasswordController.text,
//           phoneNumber:
//               _phoneController.text.isNotEmpty ? _phoneController.text : null,
//           address:
//               _addressController.text.isNotEmpty ? _addressController.text : null,
//           profilePicture: profilePath, // ✅ OPTIONAL
//         );

//     final state = ref.read(authViewModelProvider);

//     if (state.status == AuthStatus.registered) {
//       SnackbarUtils.showSuccess(context, 'Registration Successful');
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const LoginPage()),
//       );
//     } else if (state.status == AuthStatus.error) {
//       SnackbarUtils.showError(
//         context,
//         state.errorMessage ?? 'Registration Failed',
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authViewModelProvider);
//     final profilePath = authState.profilePicture;

//     return Scaffold(
//       resizeToAvoidBottomInset: true, // ✅ KEY
//       backgroundColor: const Color(0xFFD9F2D5),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: const NeverScrollableScrollPhysics(), // 👈 no manual scroll
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 const SizedBox(height: 16),
//                 const Text(
//                   "Create Account",
//                   style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 6),
//                 const Text("Sign up to continue"),
//                 const SizedBox(height: 18),

//                 /// Profile Image
//                 Column(
//                   children: [
//                     CircleAvatar(
//                       radius: 42,
//                       backgroundColor: Colors.white,
//                       backgroundImage:
//                           profilePath != null ? FileImage(File(profilePath)) : null,
//                       child: profilePath == null
//                           ? const Icon(Icons.person, size: 50, color: Colors.grey)
//                           : null,
//                     ),
//                     TextButton(
//                       child: const Text("Upload your picture"),
//                       onPressed: () {
//                         showModalBottomSheet(
//                           context: context,
//                           builder: (_) => Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               ListTile(
//                                 leading: const Icon(Icons.camera),
//                                 title: const Text('Take Photo'),
//                                 onTap: () {
//                                   Navigator.pop(context);
//                                   _pickProfileImage(true);
//                                 },
//                               ),
//                               ListTile(
//                                 leading: const Icon(Icons.photo_library),
//                                 title: const Text('Choose from Gallery'),
//                                 onTap: () {
//                                   Navigator.pop(context);
//                                   _pickProfileImage(false);
//                                 },
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 14),

//                 CustomTextField(
//                   hint: "Full Name",
//                   icon: Icons.person_outline,
//                   controller: _fullNameController,
//                   validator: (v) => v == null || v.isEmpty ? 'Required' : null,
//                 ),
//                 const SizedBox(height: 10),

//                 CustomTextField(
//                   hint: "E-mail",
//                   icon: Icons.email_outlined,
//                   controller: _emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (v) =>
//                       v == null || !v.contains('@') ? 'Invalid email' : null,
//                 ),
//                 const SizedBox(height: 10),

//                 CustomTextField(
//                   hint: "Password",
//                   icon: Icons.lock_outline,
//                   obscure: !_showPassword,
//                   controller: _passwordController,
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                         _showPassword ? Icons.visibility : Icons.visibility_off),
//                     onPressed: () =>
//                         setState(() => _showPassword = !_showPassword),
//                   ),
//                   validator: (v) =>
//                       v == null || v.length < 6 ? 'Min 6 characters' : null,
//                 ),
//                 const SizedBox(height: 10),

//                 CustomTextField(
//                   hint: "Confirm Password",
//                   icon: Icons.lock_outline,
//                   obscure: !_showConfirmPassword,
//                   controller: _confirmPasswordController,
//                   suffixIcon: IconButton(
//                     icon: Icon(_showConfirmPassword
//                         ? Icons.visibility
//                         : Icons.visibility_off),
//                     onPressed: () =>
//                         setState(() => _showConfirmPassword = !_showConfirmPassword),
//                   ),
//                   validator: (v) =>
//                       v != _passwordController.text ? 'Passwords do not match' : null,
//                 ),
//                 const SizedBox(height: 10),

//                 CustomTextField(
//                   hint: "Phone Number",
//                   icon: Icons.phone,
//                   controller: _phoneController,
//                 ),
//                 const SizedBox(height: 10),

//                 CustomTextField(
//                   hint: "Address",
//                   icon: Icons.location_on_outlined,
//                   controller: _addressController,
//                 ),

//                 Row(
//                   children: [
//                     Checkbox(
//                       value: _agreedToTerms,
//                       onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
//                     ),
//                     const Expanded(
//                       child: Text("I accept the terms and privacy policy"),
//                     ),
//                   ],
//                 ),

//                 MyButton(
//                   text: "Create Account",
//                   isLoading: authState.status == AuthStatus.loading,
//                   onPressed:
//                       authState.status == AuthStatus.loading ? null : _handleSignup,
//                 ),

//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text("Already have an account?"),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(builder: (_) => const LoginPage()),
//                         );
//                       },
//                       child: const Text("Sign in"),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:tutorix/core/widgets/custom_text_field.dart';
// import 'package:tutorix/core/widgets/my_button.dart';
// import 'package:tutorix/core/utils/snackbar_utils.dart';
// import 'package:tutorix/features/auth/presentation/state/auth_state.dart';
// import 'package:tutorix/features/auth/presentation/view_model/auth_viewmodel.dart';
// import 'login_page.dart';

// class RegisterPage extends ConsumerStatefulWidget {
//   const RegisterPage({super.key});

//   @override
//   ConsumerState<RegisterPage> createState() => _RegisterPageState();
// }

// class _RegisterPageState extends ConsumerState<RegisterPage> {
//   final _formKey = GlobalKey<FormState>();

//   final _fullNameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _addressController = TextEditingController();

//   bool _agreedToTerms = false;
//   bool _showPassword = false;
//   bool _showConfirmPassword = false;

//   @override
//   void dispose() {
//     _fullNameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     _phoneController.dispose();
//     _addressController.dispose();
//     super.dispose();
//   }

//   /// Pick profile image from camera or gallery
//   Future<void> _pickProfileImage(bool fromCamera) async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(
//       source: fromCamera ? ImageSource.camera : ImageSource.gallery,
//       imageQuality: 70,
//     );

//     if (pickedFile != null) {
//       ref.read(authViewModelProvider.notifier).setProfilePicture(pickedFile.path);
//     }
//   }

//   /// Handle signup button press
//   Future<void> _handleSignup() async {
//     if (!_agreedToTerms) {
//       SnackbarUtils.showError(context, 'Please accept Terms & Conditions');
//       return;
//     }

//     if (!_formKey.currentState!.validate()) return;

//     final authState = ref.read(authViewModelProvider);
//     final profilePath = authState.profilePicture;

//     final email = _emailController.text.trim();

//     await ref.read(authViewModelProvider.notifier).register(
//           fullName: _fullNameController.text.trim(),
//           username: email.split('@').first,
//           email: email,
//           password: _passwordController.text,
//           confirmPassword: _confirmPasswordController.text,
//           phoneNumber:
//               _phoneController.text.isNotEmpty ? _phoneController.text : null,
//           address:
//               _addressController.text.isNotEmpty ? _addressController.text : null,
//           profilePicture: profilePath, // optional
//         );

//     final state = ref.read(authViewModelProvider);

//     if (state.status == AuthStatus.registered) {
//       SnackbarUtils.showSuccess(context, 'Registration Successful');
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (_) => const LoginPage()),
//       );
//     } else if (state.status == AuthStatus.error) {
//       SnackbarUtils.showError(
//         context,
//         state.errorMessage ?? 'Registration Failed',
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authState = ref.watch(authViewModelProvider);
//     final profilePath = authState.profilePicture;

//     // Determine ImageProvider for CircleAvatar
//     ImageProvider? profileImage;
//     if (profilePath != null && profilePath.isNotEmpty) {
//       if (profilePath.startsWith('http')) {
//         profileImage = NetworkImage(profilePath);
//       } else {
//         profileImage = FileImage(File(profilePath));
//       }
//     }

//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       backgroundColor: const Color(0xFFD9F2D5),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           physics: const NeverScrollableScrollPhysics(),
//           padding: const EdgeInsets.all(24),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 const SizedBox(height: 16),
//                 const Text(
//                   "Create Account",
//                   style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 6),
//                 const Text("Sign up to continue"),
//                 const SizedBox(height: 18),

//                 /// Profile Image
//                 Column(
//                   children: [
//                     CircleAvatar(
//                       radius: 42,
//                       backgroundColor: Colors.white,
//                       backgroundImage: profileImage,
//                       child: profileImage == null
//                           ? const Icon(Icons.person, size: 50, color: Colors.grey)
//                           : null,
//                     ),
//                     TextButton(
//                       child: const Text("Upload your picture"),
//                       onPressed: () {
//                         showModalBottomSheet(
//                           context: context,
//                           builder: (_) => Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               ListTile(
//                                 leading: const Icon(Icons.camera),
//                                 title: const Text('Take Photo'),
//                                 onTap: () {
//                                   Navigator.pop(context);
//                                   _pickProfileImage(true);
//                                 },
//                               ),
//                               ListTile(
//                                 leading: const Icon(Icons.photo_library),
//                                 title: const Text('Choose from Gallery'),
//                                 onTap: () {
//                                   Navigator.pop(context);
//                                   _pickProfileImage(false);
//                                 },
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 14),

//                 CustomTextField(
//                   hint: "Full Name",
//                   icon: Icons.person_outline,
//                   controller: _fullNameController,
//                   validator: (v) => v == null || v.isEmpty ? 'Required' : null,
//                 ),
//                 const SizedBox(height: 10),

//                 CustomTextField(
//                   hint: "E-mail",
//                   icon: Icons.email_outlined,
//                   controller: _emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (v) =>
//                       v == null || !v.contains('@') ? 'Invalid email' : null,
//                 ),
//                 const SizedBox(height: 10),

//                 CustomTextField(
//                   hint: "Password",
//                   icon: Icons.lock_outline,
//                   obscure: !_showPassword,
//                   controller: _passwordController,
//                   suffixIcon: IconButton(
//                     icon: Icon(
//                         _showPassword ? Icons.visibility : Icons.visibility_off),
//                     onPressed: () =>
//                         setState(() => _showPassword = !_showPassword),
//                   ),
//                   validator: (v) =>
//                       v == null || v.length < 6 ? 'Min 6 characters' : null,
//                 ),
//                 const SizedBox(height: 10),

//                 CustomTextField(
//                   hint: "Confirm Password",
//                   icon: Icons.lock_outline,
//                   obscure: !_showConfirmPassword,
//                   controller: _confirmPasswordController,
//                   suffixIcon: IconButton(
//                     icon: Icon(_showConfirmPassword
//                         ? Icons.visibility
//                         : Icons.visibility_off),
//                     onPressed: () =>
//                         setState(() => _showConfirmPassword = !_showConfirmPassword),
//                   ),
//                   validator: (v) =>
//                       v != _passwordController.text ? 'Passwords do not match' : null,
//                 ),
//                 const SizedBox(height: 10),

//                 CustomTextField(
//                   hint: "Phone Number",
//                   icon: Icons.phone,
//                   controller: _phoneController,
//                 ),
//                 const SizedBox(height: 10),

//                 CustomTextField(
//                   hint: "Address",
//                   icon: Icons.location_on_outlined,
//                   controller: _addressController,
//                 ),

//                 Row(
//                   children: [
//                     Checkbox(
//                       value: _agreedToTerms,
//                       onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
//                     ),
//                     const Expanded(
//                       child: Text("I accept the terms and privacy policy"),
//                     ),
//                   ],
//                 ),

//                 MyButton(
//                   text: "Create Account",
//                   isLoading: authState.status == AuthStatus.loading,
//                   onPressed: authState.status == AuthStatus.loading ? null : _handleSignup,
//                 ),

//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Text("Already have an account?"),
//                     TextButton(
//                       onPressed: () {
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(builder: (_) => const LoginPage()),
//                         );
//                       },
//                       child: const Text("Sign in"),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }




import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:tutorix/core/widgets/custom_text_field.dart';
import 'package:tutorix/core/widgets/my_button.dart';
import 'package:tutorix/core/utils/snackbar_utils.dart';
import 'package:tutorix/features/auth/presentation/state/auth_state.dart';
import 'package:tutorix/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'login_page.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _agreedToTerms = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // ================= PERMISSION HANDLING =================

  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.status;

    if (status.isGranted) return true;

    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      _showPermissionDialog();
      return false;
    }

    return false;
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text(
          "Camera or Gallery permission is required to upload your profile picture. Please enable it from settings.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  /// Pick profile image (camera / gallery)
  Future<void> _pickProfileImage(bool fromCamera) async {
    final picker = ImagePicker();

    final hasPermission = fromCamera
        ? await _requestPermission(Permission.camera)
        : await _requestPermission(Permission.photos);

    if (!hasPermission) return;

    final pickedFile = await picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 70,
    );

    if (pickedFile != null) {
      ref
          .read(authViewModelProvider.notifier)
          .setProfilePicture(pickedFile.path);
    }
  }

  // ================= SIGN UP =================

  Future<void> _handleSignup() async {
    if (!_agreedToTerms) {
      SnackbarUtils.showError(context, 'Please accept Terms & Conditions');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final authState = ref.read(authViewModelProvider);
    final profilePath = authState.profilePicture;
    final email = _emailController.text.trim();

    await ref.read(authViewModelProvider.notifier).register(
          fullName: _fullNameController.text.trim(),
          username: email.split('@').first,
          email: email,
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
          phoneNumber:
              _phoneController.text.isNotEmpty ? _phoneController.text : null,
          address:
              _addressController.text.isNotEmpty ? _addressController.text : null,
          profilePicture: profilePath,
        );

    final state = ref.read(authViewModelProvider);

    if (state.status == AuthStatus.registered) {
      SnackbarUtils.showSuccess(context, 'Registration Successful');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else if (state.status == AuthStatus.error) {
      SnackbarUtils.showError(
        context,
        state.errorMessage ?? 'Registration Failed',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final profilePath = authState.profilePicture;

    ImageProvider? profileImage;
    if (profilePath != null && profilePath.isNotEmpty) {
      profileImage = profilePath.startsWith('http')
          ? NetworkImage(profilePath)
          : FileImage(File(profilePath));
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFD9F2D5),
      body: SafeArea(
        child: SingleChildScrollView(
          // physics: const NeverScrollableScrollPhysics(),
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Text(
                  "Create Account",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text("Sign up to continue"),
                const SizedBox(height: 18),

                /// PROFILE IMAGE
                Column(
                  children: [
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.white,
                      backgroundImage: profileImage,
                      child: profileImage == null
                          ? const Icon(Icons.person,
                              size: 50, color: Colors.grey)
                          : null,
                    ),
                    TextButton(
                      child: const Text("Upload your picture"),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (_) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.camera),
                                title: const Text('Take Photo'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickProfileImage(true);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.photo_library),
                                title: const Text('Choose from Gallery'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickProfileImage(false);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                CustomTextField(
                  hint: "Full Name",
                  icon: Icons.person_outline,
                  controller: _fullNameController,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 10),

                CustomTextField(
                  hint: "E-mail",
                  icon: Icons.email_outlined,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      v == null || !v.contains('@') ? 'Invalid email' : null,
                ),
                const SizedBox(height: 10),

                CustomTextField(
                  hint: "Password",
                  icon: Icons.lock_outline,
                  obscure: !_showPassword,
                  controller: _passwordController,
                  suffixIcon: IconButton(
                    icon: Icon(
                        _showPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () =>
                        setState(() => _showPassword = !_showPassword),
                  ),
                  validator: (v) =>
                      v == null || v.length < 6 ? 'Min 6 characters' : null,
                ),
                const SizedBox(height: 10),

                CustomTextField(
                  hint: "Confirm Password",
                  icon: Icons.lock_outline,
                  obscure: !_showConfirmPassword,
                  controller: _confirmPasswordController,
                  suffixIcon: IconButton(
                    icon: Icon(_showConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () => setState(
                        () => _showConfirmPassword = !_showConfirmPassword),
                  ),
                  validator: (v) => v != _passwordController.text
                      ? 'Passwords do not match'
                      : null,
                ),
                const SizedBox(height: 10),

                CustomTextField(
                  hint: "Phone Number",
                  icon: Icons.phone,
                  controller: _phoneController,
                ),
                const SizedBox(height: 10),

                CustomTextField(
                  hint: "Address",
                  icon: Icons.location_on_outlined,
                  controller: _addressController,
                ),

                Row(
                  children: [
                    Checkbox(

                      value: _agreedToTerms,
                      onChanged: (v) =>
                          setState(() => _agreedToTerms = v ?? false),
                    ),
                    const Expanded(
                      child: Text("I accept the terms and privacy policy"),
                    ),
                  ],
                ),

                MyButton(


                  text: "Create Account",
                  isLoading: authState.status == AuthStatus.loading,
                  onPressed:
                      authState.status == AuthStatus.loading ? null : _handleSignup,
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      child: const Text("Sign in"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

