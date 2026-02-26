import 'package:flutter/material.dart';
import 'package:tutorix/features/dashboard/presentation/pages/booking_store.dart';
import 'package:tutorix/features/dashboard/presentation/pages/payment_gateway_page.dart';

class ConfirmAndPayPage extends StatefulWidget {
  const ConfirmAndPayPage({
    super.key,
    required this.tutorName,
    required this.tutorProfileImage,
    required this.dateLabel,
    required this.timeLabel,
    required this.sessionRate,
    required this.durationMinutes,
    required this.totalPrice,
  });

  final String tutorName;
  final String tutorProfileImage;
  final String dateLabel;
  final String timeLabel;
  final double sessionRate;
  final int durationMinutes;
  final double totalPrice;

  @override
  State<ConfirmAndPayPage> createState() => _ConfirmAndPayPageState();
}

class _ConfirmAndPayPageState extends State<ConfirmAndPayPage> {
  String _selectedPayment = 'Khalti';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Confirm and Pay'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _TutorAvatar(imageUrl: widget.tutorProfileImage),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.tutorName,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${widget.dateLabel}, ${widget.timeLabel}',
                              style: const TextStyle(fontSize: 10, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  _summaryRow('Session Rate', 'Rs ${widget.sessionRate.toStringAsFixed(0)} / hr'),
                  _summaryRow('Date', widget.dateLabel),
                  _summaryRow('Time', widget.timeLabel),
                  _summaryRow('Duration', '${widget.durationMinutes} min'),
                  _summaryRow('Total Price', 'Rs ${widget.totalPrice.toStringAsFixed(0)}', isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Choose Payment Method',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 8),
            _paymentTile('Khalti'),
            _paymentTile('E-Sewa'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final booking = BookingRecord(
                    tutorName: widget.tutorName,
                    tutorImage: widget.tutorProfileImage,
                    dateLabel: widget.dateLabel,
                    timeLabel: widget.timeLabel,
                    sessionRate: widget.sessionRate,
                    durationMinutes: widget.durationMinutes,
                    totalPrice: widget.totalPrice,
                    paymentMethod: _selectedPayment,
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentGatewayPage(
                        method: _selectedPayment,
                        booking: booking,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F7F4F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                ),
                child: Text(
                  'Pay Rs ${widget.totalPrice.toStringAsFixed(0)} with $_selectedPayment',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentTile(String method) {
    final selected = _selectedPayment == method;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: ListTile(
        minTileHeight: 52,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        title: Text(method, style: const TextStyle(fontSize: 12)),
        trailing: Radio<String>(
          value: method,
          groupValue: _selectedPayment,
          onChanged: (value) {
            if (value == null) return;
            setState(() => _selectedPayment = value);
          },
        ),
        onTap: () => setState(() => _selectedPayment = method),
      ),
    );
  }

  Widget _summaryRow(String key, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(key, style: const TextStyle(fontSize: 11))),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorAvatar extends StatelessWidget {
  const _TutorAvatar({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.trim().isEmpty) {
      return const CircleAvatar(
        radius: 18,
        backgroundColor: Color(0xFFE2E8F0),
        child: Icon(Icons.person, color: Colors.black54),
      );
    }

    return ClipOval(
      child: Image.network(
        imageUrl,
        width: 36,
        height: 36,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFE2E8F0),
            child: Icon(Icons.person, color: Colors.black54),
          );
        },
      ),
    );
  }
}
