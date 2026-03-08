import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/features/messages/data/datasources/messages_datasource.dart';
import 'package:tutorix/features/messages/data/datasources/local/messages_local_datasource.dart';
import 'package:tutorix/features/messages/data/datasources/remote/messages_remote_datasource.dart';
import 'package:tutorix/features/messages/domain/repositories/messages_repository.dart';

final messagesRepositoryImplProvider = Provider<IMessagesRepository>((ref) {
  final remoteDatasource = ref.read(messagesRemoteDatasourceProvider);
  final localDatasource = ref.read(messagesLocalDatasourceProvider);
  return MessagesRepositoryImpl(
    remoteDatasource: remoteDatasource,
    localDatasource: localDatasource,
  );
});

class MessagesRepositoryImpl implements IMessagesRepository {
  MessagesRepositoryImpl({
    required IMessagesDatasource remoteDatasource,
    required IMessagesDatasource localDatasource,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource;

  final IMessagesDatasource _remoteDatasource;
  final IMessagesDatasource _localDatasource;

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getConversations() async {
    try {
      final result = await _remoteDatasource.getConversations();
      return Right(result);
    } catch (e) {
      try {
        final cached = await _localDatasource.getConversations();
        return Right(cached);
      } catch (_) {
        return Left(ApiFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    try {
      final result = await _remoteDatasource.sendMessage(
        conversationId: conversationId,
        content: content,
      );
      await _localDatasource.sendMessage(
        conversationId: conversationId,
        content: content,
      );
      return Right(result);
    } catch (e) {
      try {
        final cached = await _localDatasource.sendMessage(
          conversationId: conversationId,
          content: content,
        );
        return Right(cached);
      } catch (_) {
        return Left(ApiFailure(message: e.toString()));
      }
    }
  }
}
