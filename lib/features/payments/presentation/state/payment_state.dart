class PaymentState {
  const PaymentState({
    this.isInitiating = false,
    this.isVerifying = false,
    this.errorMessage,
    this.paymentSession,
    this.isPaymentVerified = false,
  });

  final bool isInitiating;
  final bool isVerifying;
  final String? errorMessage;
  final Map<String, dynamic>? paymentSession;
  final bool isPaymentVerified;

  PaymentState copyWith({
    bool? isInitiating,
    bool? isVerifying,
    String? errorMessage,
    bool clearError = false,
    Map<String, dynamic>? paymentSession,
    bool? isPaymentVerified,
  }) {
    return PaymentState(
      isInitiating: isInitiating ?? this.isInitiating,
      isVerifying: isVerifying ?? this.isVerifying,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      paymentSession: paymentSession ?? this.paymentSession,
      isPaymentVerified: isPaymentVerified ?? this.isPaymentVerified,
    );
  }
}
