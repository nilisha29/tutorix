import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9F2D5), // same theme color

      appBar: AppBar(
        backgroundColor: const Color(0xFFBEE5B0),
        elevation: 0,
        title: const Text(
          "HomeScreen",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),

      body: const Center(
        child: Text(
          "This is Home Page",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
