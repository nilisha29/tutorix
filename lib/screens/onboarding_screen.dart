// import 'package:flutter/material.dart';
// import 'onboarding_page1.dart';
// import 'onboarding_page2.dart';
// import 'onboarding_page3.dart';
// import 'welcome_page.dart';

// class OnboardingScreen extends StatefulWidget {
//   const OnboardingScreen({super.key});

//   @override
//   State<OnboardingScreen> createState() => _OnboardingScreenState();
// }

// class _OnboardingScreenState extends State<OnboardingScreen> {
//   final PageController _controller = PageController();

//   void goToWelcome(BuildContext context) {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => const WelcomePage()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFCEEDD2),
//       body: PageView(
//         controller: _controller,
//         children: [
//           OnboardingPage1(
//             onSkip: () => goToWelcome(context),
//             onNext: () => _controller.nextPage(
//               duration: const Duration(milliseconds: 400),
//               curve: Curves.easeOut,
//             ),
//           ),

//           OnboardingPage2(
//             onSkip: () => goToWelcome(context),
//             onNext: () => _controller.nextPage(
//               duration: const Duration(milliseconds: 400),
//               curve: Curves.easeOut,
//             ),
//           ),

//           OnboardingPage3(
//             onSkip: () => goToWelcome(context),
//             onNext: () => goToWelcome(context),
//           ),
//         ],
//       ),
//     );
//   }
// }




