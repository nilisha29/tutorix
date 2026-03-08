import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/api/api_client.dart';
import 'package:tutorix/features/payments/data/datasources/payment_datasource.dart';

final paymentRemoteDatasourceProvider = Provider<IPaymentDatasource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return PaymentRemoteDatasource(apiClient: apiClient);
});

class PaymentRemoteDatasource implements IPaymentDatasource {
  PaymentRemoteDatasource({required ApiClient apiClient});

  @override
  Future<Map<String, dynamic>> initiatePayment(Map<String, dynamic> paymentPayload) async {
    return <String, dynamic>{'status': 'initiated', 'payload': paymentPayload};
  }

  @override
  Future<bool> verifyPayment({required String transactionId, required String gateway}) async {
    return true;
  }
}
