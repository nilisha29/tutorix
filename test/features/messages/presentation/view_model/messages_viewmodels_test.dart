import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tutorix/core/error/failures.dart';
import 'package:tutorix/features/messages/domain/usecases/get_conversations_usecase.dart';
import 'package:tutorix/features/messages/domain/usecases/send_message_usecase.dart';
import 'package:tutorix/features/messages/presentation/view_model/chat_viewmodel.dart';
import 'package:tutorix/features/messages/presentation/view_model/conversations_viewmodel.dart';

class MockGetConversationsUseCase extends Mock implements GetConversationsUseCase {}

class MockSendMessageUseCase extends Mock implements SendMessageUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const SendMessageUseCaseParams(conversationId: 'c1', content: 'hello'),
    );
  });

  group('Messages ViewModels', () {
    test('ConversationsViewModel sets items on success', () async {
      final useCase = MockGetConversationsUseCase();
      final items = [
        {'id': 'c1'}
      ];
      when(() => useCase()).thenAnswer((_) async => Right(items));
      final vm = ConversationsViewModel(getConversationsUseCase: useCase);

      await vm.fetchConversations();

      expect(vm.state.items, items);
      expect(vm.state.errorMessage, isNull);
    });

    test('ChatViewModel sendMessage appends message on success', () async {
      final useCase = MockSendMessageUseCase();
      final msg = {'id': 'm1', 'content': 'Hi'};
      when(() => useCase(any())).thenAnswer((_) async => Right(msg));
      final vm = ChatViewModel(sendMessageUseCase: useCase);

      await vm.sendMessage(conversationId: 'c1', content: 'Hi');

      expect(vm.state.isSending, false);
      expect(vm.state.messages.last, msg);
      expect(vm.state.errorMessage, isNull);
    });

    test('ChatViewModel sendMessage ignores empty content', () async {
      final useCase = MockSendMessageUseCase();
      final vm = ChatViewModel(sendMessageUseCase: useCase);

      await vm.sendMessage(conversationId: 'c1', content: '   ');

      verifyNever(() => useCase(any()));
      expect(vm.state.messages, isEmpty);
    });

    test('ChatViewModel sets error on send failure', () async {
      final useCase = MockSendMessageUseCase();
      const failure = NetworkFailure(message: 'offline');
      when(() => useCase(any())).thenAnswer((_) async => const Left(failure));
      final vm = ChatViewModel(sendMessageUseCase: useCase);

      await vm.sendMessage(conversationId: 'c1', content: 'hello');

      expect(vm.state.isSending, false);
      expect(vm.state.errorMessage, failure.message);
    });
  });
}
