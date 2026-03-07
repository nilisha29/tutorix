import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/features/messages/domain/repositories/messages_repository.dart';
import 'package:tutorix/features/messages/domain/usecases/get_conversations_usecase.dart';
import 'package:tutorix/features/messages/domain/usecases/send_message_usecase.dart';

class MockMessagesRepository extends Mock implements IMessagesRepository {}

void main() {
  late MockMessagesRepository repository;
  late GetConversationsUseCase getConversationsUseCase;
  late SendMessageUseCase sendMessageUseCase;

  setUp(() {
    repository = MockMessagesRepository();
    getConversationsUseCase = GetConversationsUseCase(messagesRepository: repository);
    sendMessageUseCase = SendMessageUseCase(messagesRepository: repository);
  });

  group('Messages usecases', () {
    test('GetConversationsUseCase returns list on success', () async {
      final conversations = [
        {'id': 'c1', 'lastMessage': 'Hello'},
      ];
      when(() => repository.getConversations()).thenAnswer((_) async => Right(conversations));

      final result = await getConversationsUseCase();

      expect(result, Right(conversations));
      verify(() => repository.getConversations()).called(1);
    });

    test('GetConversationsUseCase returns failure on error', () async {
      const failure = NetworkFailure(message: 'Offline');
      when(() => repository.getConversations()).thenAnswer((_) async => const Left(failure));

      final result = await getConversationsUseCase();

      expect(result, const Left(failure));
    });

    test('SendMessageUseCase forwards params and returns message', () async {
      const params = SendMessageUseCaseParams(
        conversationId: 'c1',
        content: 'Hi tutor',
      );
      final message = {'id': 'm1', 'content': 'Hi tutor'};

      when(() => repository.sendMessage(conversationId: any(named: 'conversationId'), content: any(named: 'content')))
          .thenAnswer((_) async => Right(message));

      final result = await sendMessageUseCase(params);

      expect(result, Right(message));
      verify(() => repository.sendMessage(
            conversationId: params.conversationId,
            content: params.content,
          )).called(1);
    });

    test('SendMessageUseCase returns failure on error', () async {
      const params = SendMessageUseCaseParams(conversationId: 'c1', content: 'Hi');
      const failure = ApiFailure(message: 'Send failed', statusCode: 500);

      when(() => repository.sendMessage(conversationId: any(named: 'conversationId'), content: any(named: 'content')))
          .thenAnswer((_) async => const Left(failure));

      final result = await sendMessageUseCase(params);

      expect(result, const Left(failure));
    });
  });
}
