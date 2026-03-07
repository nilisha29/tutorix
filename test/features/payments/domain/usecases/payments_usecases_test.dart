import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/features/payments/domain/repositories/payment_repository.dart';
import 'package:tutorix/features/payments/domain/usecases/initiate_payment_usecase.dart';
import 'package:tutorix/features/payments/domain/usecases/verify_payment_usecase.dart';

class MockPaymentRepository extends Mock implements IPaymentRepository {}

void main() {
  late MockPaymentRepository repository;
  late InitiatePaymentUseCase initiatePaymentUseCase;
  late VerifyPaymentUseCase verifyPaymentUseCase;

  setUp(() {
    repository = MockPaymentRepository();
    initiatePaymentUseCase = InitiatePaymentUseCase(paymentRepository: repository);
    verifyPaymentUseCase = VerifyPaymentUseCase(paymentRepository: repository);
  });

  group('Payments usecases', () {
    test('InitiatePaymentUseCase forwards payload and returns session', () async {
      const params = InitiatePaymentUseCaseParams(
        bookingId: 'b1',
        amount: 1200,
        gateway: 'khalti',
        payerName: 'John',
        payerPhone: '9800000000',
      );
      final session = {'paymentUrl': 'https://gateway'};

      when(() => repository.initiatePayment(any())).thenAnswer((_) async => Right(session));

      final result = await initiatePaymentUseCase(params);

      expect(result, Right(session));
      verify(() => repository.initiatePayment(params.toJson())).called(1);
    });

    test('InitiatePaymentUseCase returns failure on error', () async {
      const params = InitiatePaymentUseCaseParams(
        bookingId: 'b1',
        amount: 1200,
        gateway: 'khalti',
        payerName: 'John',
        payerPhone: '9800000000',
      );
      const failure = ApiFailure(message: 'Payment init failed', statusCode: 400);

      when(() => repository.initiatePayment(any())).thenAnswer((_) async => const Left(failure));

      final result = await initiatePaymentUseCase(params);

      expect(result, const Left(failure));
    });

    test('VerifyPaymentUseCase forwards params and returns true', () async {
      const params = VerifyPaymentUseCaseParams(
        transactionId: 'txn-1',
        gateway: 'esewa',
      );
      when(() => repository.verifyPayment(
            transactionId: any(named: 'transactionId'),
            gateway: any(named: 'gateway'),
          )).thenAnswer((_) async => const Right(true));

      final result = await verifyPaymentUseCase(params);

      expect(result, const Right(true));
      verify(() => repository.verifyPayment(
            transactionId: params.transactionId,
            gateway: params.gateway,
          )).called(1);
    });

    test('VerifyPaymentUseCase returns failure on error', () async {
      const params = VerifyPaymentUseCaseParams(
        transactionId: 'txn-1',
        gateway: 'esewa',
      );
      const failure = NetworkFailure(message: 'Timeout');

      when(() => repository.verifyPayment(
            transactionId: any(named: 'transactionId'),
            gateway: any(named: 'gateway'),
          )).thenAnswer((_) async => const Left(failure));

      final result = await verifyPaymentUseCase(params);

      expect(result, const Left(failure));
    });
  });
}
