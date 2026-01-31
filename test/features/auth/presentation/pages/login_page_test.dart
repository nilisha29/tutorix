import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tutorix/features/auth/domain/entities/auth_entity.dart';
import 'package:tutorix/features/auth/domain/usecases/login_usecase.dart';
import 'package:tutorix/features/auth/domain/usecases/register_usecase.dart';
import 'package:tutorix/features/auth/domain/usecases/logout_usecase.dart';
import 'package:tutorix/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:tutorix/features/auth/presentation/pages/login_page.dart';
import 'package:tutorix/features/auth/presentation/state/auth_state.dart';
import 'package:tutorix/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:tutorix/core/error/failures.dart';


/// ---------------- MOCK CLASSES ----------------
class MockLoginUsecase extends Mock implements LoginUsecase {}
class MockRegisterUsecase extends Mock implements RegisterUsecase {}
class MockLogoutUsecase extends Mock implements LogoutUsecase {}
class MockGetCurrentUserUsecase extends Mock implements GetCurrentUserUsecase {}

void main() {
  late MockLoginUsecase mockLoginUsecase;
  late MockRegisterUsecase mockRegisterUsecase;
  late MockLogoutUsecase mockLogoutUsecase;
  late MockGetCurrentUserUsecase mockGetCurrentUserUsecase;

  setUpAll(() {
    registerFallbackValue(
      const LoginUsecaseParams(email: 'test@test.com', password: 'password123'),
    );
  });

  setUp(() {
    mockLoginUsecase = MockLoginUsecase();
    mockRegisterUsecase = MockRegisterUsecase();
    mockLogoutUsecase = MockLogoutUsecase();
    mockGetCurrentUserUsecase = MockGetCurrentUserUsecase();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        registerUsecaseProvider.overrideWithValue(mockRegisterUsecase),
        logoutUsecaseProvider.overrideWithValue(mockLogoutUsecase),
        getCurrentUserUsecaseProvider.overrideWithValue(
          mockGetCurrentUserUsecase,
        ),
      ],
      child: const MaterialApp(home: LoginPage()),
    );
  }

  /// ---------------- UI TESTS ----------------
  group('LoginPage UI Tests', () {
    testWidgets('should display login texts and button', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('Sign in to your Tutorix account'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
    });

    testWidgets('should display email and password fields', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('should display forgot password text', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Forgot your password?'), findsOneWidget);
    });

    testWidgets('should display create account link', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Create Account'), findsOneWidget);
    });
  });

  /// ---------------- VALIDATION TESTS ----------------
  group('LoginPage Validation Tests', () {
    testWidgets('should show error when email is empty', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.ensureVisible(find.text('Sign in'));
      await tester.tap(find.text('Sign in'));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('should show error for invalid email', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextFormField).first, 'invalid');
      await tester.ensureVisible(find.text('Sign in'));
      await tester.tap(find.text('Sign in'));
      await tester.pump();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('should show error for short password', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextFormField).first, 'test@test.com');
      await tester.enterText(find.byType(TextFormField).last, '123');
      await tester.ensureVisible(find.text('Sign in'));
      await tester.tap(find.text('Sign in'));
      await tester.pump();

      expect(
        find.text('Password must be at least 6 characters'),
        findsOneWidget,
      );
    });
  });

  /// ---------------- SUBMISSION TESTS ----------------
  group('LoginPage Submission Tests', () {
    testWidgets('should call login usecase on valid input', (tester) async {
      final completer = Completer<Either<Failure, AuthEntity>>();

      when(() => mockLoginUsecase(any())).thenAnswer(
        (_) => completer.future,
      );

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextFormField).first, 'test@test.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');

      await tester.ensureVisible(find.text('Sign in'));
      await tester.tap(find.text('Sign in'));
      await tester.pump();

      verify(() => mockLoginUsecase(any())).called(1);
    });

    testWidgets('should show loading indicator during login', (tester) async {
      final completer = Completer<Either<Failure, AuthEntity>>();

      when(() => mockLoginUsecase(any())).thenAnswer(
        (_) => completer.future,
      );

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextFormField).first, 'test@test.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');

      await tester.ensureVisible(find.text('Sign in'));
      await tester.tap(find.text('Sign in'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}

