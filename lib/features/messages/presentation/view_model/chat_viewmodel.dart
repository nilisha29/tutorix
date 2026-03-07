import 'package:flutter_riverpod/legacy.dart';
import 'package:tutorix/features/messages/domain/usecases/send_message_usecase.dart';
import 'package:tutorix/features/messages/presentation/state/chat_state.dart';

class ChatViewModel extends StateNotifier<ChatState> {
  ChatViewModel({required SendMessageUseCase sendMessageUseCase})
      : _sendMessageUseCase = sendMessageUseCase,
        super(const ChatState());

  final SendMessageUseCase _sendMessageUseCase;

  void setInitialMessages(List<Map<String, dynamic>> initialMessages) {
    state = state.copyWith(messages: initialMessages, clearError: true);
  }

  Future<void> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return;

    state = state.copyWith(isSending: true, clearError: true);

    final result = await _sendMessageUseCase(
      SendMessageUseCaseParams(
        conversationId: conversationId,
        content: trimmed,
      ),
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          isSending: false,
          errorMessage: failure.message,
        );
      },
      (message) {
        final updatedMessages = [...state.messages, message];
        state = state.copyWith(
          isSending: false,
          messages: updatedMessages,
          clearError: true,
        );
      },
    );
  }
}

final chatViewModelProvider = StateNotifierProvider<ChatViewModel, ChatState>((ref) {
  return ChatViewModel(
    sendMessageUseCase: ref.read(sendMessageUseCaseProvider),
  );
});
