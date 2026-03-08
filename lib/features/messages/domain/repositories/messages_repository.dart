import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/features/messages/data/repositories/messages_repository_impl.dart';

abstract interface class IMessagesRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getConversations();

  Future<Either<Failure, Map<String, dynamic>>> sendMessage({
    required String conversationId,
    required String content,
  });
}

final messagesRepositoryProvider = Provider<IMessagesRepository>((ref) {
  return ref.read(messagesRepositoryImplProvider);
});
