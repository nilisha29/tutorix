import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorix/features/auth/presentation/pages/reset_password_page.dart';

void main() {
  Widget createTestWidget({String initialEmail = ''}) {
    return ProviderScope(
      child: MaterialApp(
        home: ResetPasswordPage(initialEmail: initialEmail),
      ),
    );
  }

  group('ResetPasswordPage Widget Tests', () {
    testWidgets('shows app bar and key action buttons', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Reset Password'), findsOneWidget);
      expect(find.text('Send Reset Link'), findsOneWidget);
    });

    testWidgets('shows initial form fields before link is sent', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Reset Token or Link'), findsNothing);
      expect(find.text('New Password'), findsNothing);
      expect(find.text('Confirm Password'), findsNothing);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('prefills email when initialEmail provided', (tester) async {
      const email = 'prefill@test.com';
      await tester.pumpWidget(createTestWidget(initialEmail: email));

      expect(find.text(email), findsOneWidget);
    });

    testWidgets('shows validation error when email is empty and send link tapped', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Send Reset Link'));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
    });
  });
}
