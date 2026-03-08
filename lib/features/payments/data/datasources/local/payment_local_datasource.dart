import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/features/payments/data/datasources/payment_datasource.dart';

final paymentLocalDatasourceProvider = Provider<IPaymentDatasource>((ref) {
  return PaymentLocalDatasource();
});

class PaymentLocalDatasource implements IPaymentDatasource {
  @override
  Future<Map<String, dynamic>> initiatePayment(Map<String, dynamic> paymentPayload) async {
    return <String, dynamic>{'status': 'cached', 'payload': paymentPayload};
  }

  @override
  Future<bool> verifyPayment({required String transactionId, required String gateway}) async {
    return true;
  }
}
