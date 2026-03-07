import 'package:flutter_riverpod/legacy.dart';
import 'package:tutorix/features/payments/domain/usecases/initiate_payment_usecase.dart';
import 'package:tutorix/features/payments/domain/usecases/verify_payment_usecase.dart';
import 'package:tutorix/features/payments/presentation/state/payment_state.dart';

class PaymentViewModel extends StateNotifier<PaymentState> {
  PaymentViewModel({
    required InitiatePaymentUseCase initiatePaymentUseCase,
    required VerifyPaymentUseCase verifyPaymentUseCase,
  })  : _initiatePaymentUseCase = initiatePaymentUseCase,
        _verifyPaymentUseCase = verifyPaymentUseCase,
        super(const PaymentState());

  final InitiatePaymentUseCase _initiatePaymentUseCase;
  final VerifyPaymentUseCase _verifyPaymentUseCase;

  Future<void> initiatePayment(InitiatePaymentUseCaseParams params) async {
    state = state.copyWith(
      isInitiating: true,
      clearError: true,
      isPaymentVerified: false,
    );

    final result = await _initiatePaymentUseCase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          isInitiating: false,
          errorMessage: failure.message,
        );
      },
      (paymentSession) {
        state = state.copyWith(
          isInitiating: false,
          paymentSession: paymentSession,
          clearError: true,
        );
      },
    );
  }

  Future<void> verifyPayment(VerifyPaymentUseCaseParams params) async {
    state = state.copyWith(isVerifying: true, clearError: true);
    final result = await _verifyPaymentUseCase(params);

    result.fold(
      (failure) {
        state = state.copyWith(
          isVerifying: false,
          errorMessage: failure.message,
          isPaymentVerified: false,
        );
      },
      (isVerified) {
        state = state.copyWith(
          isVerifying: false,
          isPaymentVerified: isVerified,
          clearError: true,
        );
      },
    );
  }
}

final paymentViewModelProvider =
    StateNotifierProvider<PaymentViewModel, PaymentState>((ref) {
  return PaymentViewModel(
    initiatePaymentUseCase: ref.read(initiatePaymentUseCaseProvider),
    verifyPaymentUseCase: ref.read(verifyPaymentUseCaseProvider),
  );
});
