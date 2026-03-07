import 'package:flutter_riverpod/legacy.dart';
import 'package:tutorix/features/messages/domain/usecases/get_conversations_usecase.dart';
import 'package:tutorix/features/messages/presentation/state/conversations_state.dart';

class ConversationsViewModel extends StateNotifier<ConversationsState> {
  ConversationsViewModel({
    required GetConversationsUseCase getConversationsUseCase,
  })  : _getConversationsUseCase = getConversationsUseCase,
        super(const ConversationsState());

  final GetConversationsUseCase _getConversationsUseCase;

  Future<void> fetchConversations() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _getConversationsUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (items) {
        state = state.copyWith(
          isLoading: false,
          items: items,
          clearError: true,
        );
      },
    );
  }
}

final conversationsViewModelProvider =
    StateNotifierProvider<ConversationsViewModel, ConversationsState>((ref) {
  return ConversationsViewModel(
    getConversationsUseCase: ref.read(getConversationsUseCaseProvider),
  );
});
