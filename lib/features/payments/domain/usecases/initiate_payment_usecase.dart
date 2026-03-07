import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/core/usecases/app_usecase.dart';
import 'package:tutorix/features/payments/domain/repositories/payment_repository.dart';

class InitiatePaymentUseCaseParams extends Equatable {
  const InitiatePaymentUseCaseParams({
    required this.bookingId,
    required this.amount,
    required this.gateway,
    required this.payerName,
    required this.payerPhone,
  });

  final String bookingId;
  final double amount;
  final String gateway;
  final String payerName;
  final String payerPhone;

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'amount': amount,
      'gateway': gateway,
      'payerName': payerName,
      'payerPhone': payerPhone,
    };
  }

  @override
  List<Object?> get props => [bookingId, amount, gateway, payerName, payerPhone];
}

class InitiatePaymentUseCase
    implements UsecaseWithParams<Map<String, dynamic>, InitiatePaymentUseCaseParams> {
  InitiatePaymentUseCase({required IPaymentRepository paymentRepository})
      : _paymentRepository = paymentRepository;

  final IPaymentRepository _paymentRepository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    InitiatePaymentUseCaseParams params,
  ) {
    return _paymentRepository.initiatePayment(params.toJson());
  }
}

final initiatePaymentUseCaseProvider = Provider<InitiatePaymentUseCase>((ref) {
  return InitiatePaymentUseCase(
    paymentRepository: ref.read(paymentRepositoryProvider),
  );
});
