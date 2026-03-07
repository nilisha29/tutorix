import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/core/usecases/app_usecase.dart';
import 'package:tutorix/features/messages/domain/repositories/messages_repository.dart';

class GetConversationsUseCase
    implements UsecaseWithoutParams<List<Map<String, dynamic>>> {
  GetConversationsUseCase({required IMessagesRepository messagesRepository})
      : _messagesRepository = messagesRepository;

  final IMessagesRepository _messagesRepository;

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call() {
    return _messagesRepository.getConversations();
  }
}

final getConversationsUseCaseProvider = Provider<GetConversationsUseCase>((ref) {
  return GetConversationsUseCase(
    messagesRepository: ref.read(messagesRepositoryProvider),
  );
});
