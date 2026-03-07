import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';

abstract interface class IPaymentRepository {
  Future<Either<Failure, Map<String, dynamic>>> initiatePayment(
    Map<String, dynamic> paymentPayload,
  );

  Future<Either<Failure, bool>> verifyPayment({
    required String transactionId,
    required String gateway,
  });
}

final paymentRepositoryProvider = Provider<IPaymentRepository>((ref) {
  throw UnimplementedError(
    'paymentRepositoryProvider must be overridden with a concrete implementation.',
  );
});
