import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorix/features/payments/presentation/pages/payment_success_page.dart';

void main() {
  Widget createTestWidget() {
    return const MaterialApp(home: PaymentSuccessPage());
  }

  group('PaymentSuccessPage Widget Tests', () {
    testWidgets('shows success labels', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Payment Successful'), findsOneWidget);
      expect(find.text('Booking Confirmed'), findsOneWidget);
    });

    testWidgets('shows view bookings button', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('View My Bookings'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('shows success icon', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });
}
