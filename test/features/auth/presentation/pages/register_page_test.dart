import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tutorix/features/auth/domain/usecases/register_usecase.dart';
import 'package:tutorix/features/auth/presentation/pages/register_page.dart';
import 'package:tutorix/features/auth/presentation/state/auth_state.dart';
import 'package:tutorix/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:tutorix/core/widgets/my_button.dart';

// ---------------- MOCKS ----------------
class MockRegisterUsecase extends Mock implements RegisterUsecase {}


void main() {
  late MockRegisterUsecase mockRegisterUsecase;

  setUpAll(() {
    registerFallbackValue(
      const RegisterUsecaseParams(
        fullName: 'fallback',
        email: 'fallback@email.com',
        username: 'fallback',
        password: 'fallback',
        confirmPassword: 'fallback',
        phoneNumber: null,
        address: null,
        profilePicture: null,
      ),
    );
  });

  setUp(() {
    mockRegisterUsecase = MockRegisterUsecase();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        registerUsecaseProvider.overrideWithValue(mockRegisterUsecase),
      ],
      child: const MaterialApp(home: RegisterPage()),
    );
  }

  group('RegisterPage UI Tests', () {
    testWidgets('should display header texts', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Sign up to continue'), findsOneWidget);
    });

    testWidgets('should display all form fields and buttons', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(6));
      expect(find.byType(Checkbox), findsOneWidget);
      expect(find.byType(MyButton), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
    });

    testWidgets('should show icons for fields', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person_outline), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsNWidgets(2));
      expect(find.byIcon(Icons.phone), findsOneWidget);
      expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
    });

    testWidgets('should show profile image placeholder', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.text('Upload your picture'), findsOneWidget);
    });
  });

  
}
