import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/core/usecases/app_usecase.dart';
import 'package:tutorix/features/messages/domain/repositories/messages_repository.dart';

class SendMessageUseCaseParams extends Equatable {
  const SendMessageUseCaseParams({
    required this.conversationId,
    required this.content,
  });

  final String conversationId;
  final String content;

  @override
  List<Object?> get props => [conversationId, content];
}

class SendMessageUseCase
    implements UsecaseWithParams<Map<String, dynamic>, SendMessageUseCaseParams> {
  SendMessageUseCase({required IMessagesRepository messagesRepository})
      : _messagesRepository = messagesRepository;

  final IMessagesRepository _messagesRepository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    SendMessageUseCaseParams params,
  ) {
    return _messagesRepository.sendMessage(
      conversationId: params.conversationId,
      content: params.content,
    );
  }
}

final sendMessageUseCaseProvider = Provider<SendMessageUseCase>((ref) {
  return SendMessageUseCase(
    messagesRepository: ref.read(messagesRepositoryProvider),
  );
});
