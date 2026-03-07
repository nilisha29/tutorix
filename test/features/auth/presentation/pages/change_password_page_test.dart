import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutorix/features/auth/presentation/pages/change_password_page.dart';

void main() {
  Widget createTestWidget() {
    return const ProviderScope(
      child: MaterialApp(home: ChangePasswordPage()),
    );
  }

  group('ChangePasswordPage Widget Tests', () {
    testWidgets('renders title and update button', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Change Password'), findsOneWidget);
      expect(find.text('Update Password'), findsOneWidget);
    });

    testWidgets('renders all password fields', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Current Password'), findsOneWidget);
      expect(find.text('New Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(3));
    });

    testWidgets('shows validation for empty current password', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Update Password'));
      await tester.pump();

      expect(find.text('Enter current password'), findsOneWidget);
    });

    testWidgets('shows mismatch validation when confirm password differs', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextFormField).at(0), 'oldpass123');
      await tester.enterText(find.byType(TextFormField).at(1), 'newpass123');
      await tester.enterText(find.byType(TextFormField).at(2), 'different123');

      await tester.tap(find.text('Update Password'));
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });
}
