import 'package:flutter/material.dart';
import 'package:tutorix/features/dashboard/presentation/pages/booking_store.dart';
import 'package:tutorix/features/dashboard/presentation/pages/payment_success_page.dart';

class PaymentGatewayPage extends StatefulWidget {
  const PaymentGatewayPage({
    super.key,
    required this.method,
    required this.booking,
  });

  final String method;
  final BookingRecord booking;

  @override
  State<PaymentGatewayPage> createState() => _PaymentGatewayPageState();
}

class _PaymentGatewayPageState extends State<PaymentGatewayPage> {
  final TextEditingController _accountController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _accountController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isKhalti = widget.method.toLowerCase().contains('khalti');
    final primaryColor = isKhalti ? const Color(0xFF5C2D91) : const Color(0xFF1D9E63);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: Text('${widget.method} Payment'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pay with ${widget.method}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: primaryColor),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Amount: Rs ${widget.booking.totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _accountController,
                    decoration: const InputDecoration(
                      labelText: 'Phone/Account ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _pinController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'MPIN / Password',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  BookingStore.addBooking(widget.booking);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const PaymentSuccessPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                ),
                child: Text('Pay Rs ${widget.booking.totalPrice.toStringAsFixed(0)}'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
