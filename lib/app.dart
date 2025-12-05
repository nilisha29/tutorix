import 'package:flutter/material.dart';
import 'package:tutorix/screens/login_screen.dart';
import 'package:tutorix/screens/onboarding_page1.dart';
import 'package:tutorix/screens/onboarding_page2.dart';
import 'package:tutorix/screens/onboarding_page3.dart';
import 'package:tutorix/screens/register_screen.dart';
import 'package:tutorix/screens/splash_screen.dart';
import 'package:tutorix/screens/welcome_page.dart';
import 'package:tutorix/widgets/my_button.dart';


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

