import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/core/usecases/app_usecase.dart';
import 'package:tutorix/features/payments/domain/repositories/payment_repository.dart';

class VerifyPaymentUseCaseParams extends Equatable {
  const VerifyPaymentUseCaseParams({
    required this.transactionId,
    required this.gateway,
  });

  final String transactionId;
  final String gateway;

  @override
  List<Object?> get props => [transactionId, gateway];
}

class VerifyPaymentUseCase
    implements UsecaseWithParams<bool, VerifyPaymentUseCaseParams> {
  VerifyPaymentUseCase({required IPaymentRepository paymentRepository})
      : _paymentRepository = paymentRepository;

  final IPaymentRepository _paymentRepository;

  @override
  Future<Either<Failure, bool>> call(VerifyPaymentUseCaseParams params) {
    return _paymentRepository.verifyPayment(
      transactionId: params.transactionId,
      gateway: params.gateway,
    );
  }
}

final verifyPaymentUseCaseProvider = Provider<VerifyPaymentUseCase>((ref) {
  return VerifyPaymentUseCase(
    paymentRepository: ref.read(paymentRepositoryProvider),
  );
});
