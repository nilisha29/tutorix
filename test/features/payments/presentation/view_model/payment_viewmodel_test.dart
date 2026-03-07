import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/features/payments/domain/usecases/initiate_payment_usecase.dart';
import 'package:tutorix/features/payments/domain/usecases/verify_payment_usecase.dart';
import 'package:tutorix/features/payments/presentation/view_model/payment_viewmodel.dart';

class MockInitiatePaymentUseCase extends Mock implements InitiatePaymentUseCase {}

class MockVerifyPaymentUseCase extends Mock implements VerifyPaymentUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const InitiatePaymentUseCaseParams(
        bookingId: 'b1',
        amount: 1200,
        gateway: 'khalti',
        payerName: 'John',
        payerPhone: '9800000000',
      ),
    );
    registerFallbackValue(
      const VerifyPaymentUseCaseParams(transactionId: 'txn', gateway: 'khalti'),
    );
  });

  group('PaymentViewModel', () {
    test('initiatePayment sets session on success', () async {
      final initiate = MockInitiatePaymentUseCase();
      final verify = MockVerifyPaymentUseCase();
      const params = InitiatePaymentUseCaseParams(
        bookingId: 'b1',
        amount: 1200,
        gateway: 'khalti',
        payerName: 'John',
        payerPhone: '9800000000',
      );
      final session = {'paymentUrl': 'https://pay'};
      when(() => initiate(params)).thenAnswer((_) async => Right(session));
      final vm = PaymentViewModel(
        initiatePaymentUseCase: initiate,
        verifyPaymentUseCase: verify,
      );

      await vm.initiatePayment(params);

      expect(vm.state.paymentSession, session);
      expect(vm.state.isInitiating, false);
      expect(vm.state.errorMessage, isNull);
    });

    test('verifyPayment sets verified flag on success', () async {
      final initiate = MockInitiatePaymentUseCase();
      final verify = MockVerifyPaymentUseCase();
      const params = VerifyPaymentUseCaseParams(
        transactionId: 'txn-1',
        gateway: 'esewa',
      );
      when(() => verify(params)).thenAnswer((_) async => const Right(true));
      final vm = PaymentViewModel(
        initiatePaymentUseCase: initiate,
        verifyPaymentUseCase: verify,
      );

      await vm.verifyPayment(params);

      expect(vm.state.isPaymentVerified, true);
      expect(vm.state.isVerifying, false);
    });

    test('verifyPayment sets error on failure', () async {
      final initiate = MockInitiatePaymentUseCase();
      final verify = MockVerifyPaymentUseCase();
      const params = VerifyPaymentUseCaseParams(
        transactionId: 'txn-1',
        gateway: 'esewa',
      );
      const failure = ApiFailure(message: 'verify failed');
      when(() => verify(params)).thenAnswer((_) async => const Left(failure));
      final vm = PaymentViewModel(
        initiatePaymentUseCase: initiate,
        verifyPaymentUseCase: verify,
      );

      await vm.verifyPayment(params);

      expect(vm.state.isPaymentVerified, false);
      expect(vm.state.errorMessage, failure.message);
    });
  });
}
