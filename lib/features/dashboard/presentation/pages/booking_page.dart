import 'package:flutter/material.dart';

class BookingPage extends StatelessWidget {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking'),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text(
          'Welcome to the Booking Page',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
