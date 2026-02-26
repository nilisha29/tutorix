import 'package:flutter/material.dart';
import 'package:tutorix/features/dashboard/presentation/pages/booking_page.dart';

class PaymentSuccessPage extends StatelessWidget {
  const PaymentSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: const BoxDecoration(
                    color: Color(0xFF8DF08A),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 78,
                      height: 78,
                      decoration: const BoxDecoration(
                        color: Color(0xFF5BDE57),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 44, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Payment Successful',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Booking Confirmed',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const BookingPage()),
                        (route) => route.isFirst,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3F7F4F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('View Booking'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
