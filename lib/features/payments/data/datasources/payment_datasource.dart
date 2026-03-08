abstract interface class IPaymentDatasource {
  Future<Map<String, dynamic>> initiatePayment(Map<String, dynamic> paymentPayload);

  Future<bool> verifyPayment({
    required String transactionId,
    required String gateway,
  });
}
