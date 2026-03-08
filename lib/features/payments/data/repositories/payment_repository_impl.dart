import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/features/payments/data/datasources/payment_datasource.dart';
import 'package:tutorix/features/payments/data/datasources/local/payment_local_datasource.dart';
import 'package:tutorix/features/payments/data/datasources/remote/payment_remote_datasource.dart';
import 'package:tutorix/features/payments/domain/repositories/payment_repository.dart';

final paymentRepositoryImplProvider = Provider<IPaymentRepository>((ref) {
  final remoteDatasource = ref.read(paymentRemoteDatasourceProvider);
  final localDatasource = ref.read(paymentLocalDatasourceProvider);
  return PaymentRepositoryImpl(
    remoteDatasource: remoteDatasource,
    localDatasource: localDatasource,
  );
});

class PaymentRepositoryImpl implements IPaymentRepository {
  PaymentRepositoryImpl({
    required IPaymentDatasource remoteDatasource,
    required IPaymentDatasource localDatasource,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource;

  final IPaymentDatasource _remoteDatasource;
  final IPaymentDatasource _localDatasource;

  @override
  Future<Either<Failure, Map<String, dynamic>>> initiatePayment(Map<String, dynamic> paymentPayload) async {
    try {
      final result = await _remoteDatasource.initiatePayment(paymentPayload);
      await _localDatasource.initiatePayment(paymentPayload);
      return Right(result);
    } catch (e) {
      try {
        final cached = await _localDatasource.initiatePayment(paymentPayload);
        return Right(cached);
      } catch (_) {
        return Left(ApiFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, bool>> verifyPayment({required String transactionId, required String gateway}) async {
    try {
      final result = await _remoteDatasource.verifyPayment(
        transactionId: transactionId,
        gateway: gateway,
      );
      await _localDatasource.verifyPayment(
        transactionId: transactionId,
        gateway: gateway,
      );
      return Right(result);
    } catch (e) {
      try {
        final cached = await _localDatasource.verifyPayment(
          transactionId: transactionId,
          gateway: gateway,
        );
        return Right(cached);
      } catch (_) {
        return Left(ApiFailure(message: e.toString()));
      }
    }
  }
}
