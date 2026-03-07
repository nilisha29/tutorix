class ChatState {
  const ChatState({
    this.isSending = false,
    this.errorMessage,
    this.messages = const [],
  });

  final bool isSending;
  final String? errorMessage;
  final List<Map<String, dynamic>> messages;

  ChatState copyWith({
    bool? isSending,
    String? errorMessage,
    bool clearError = false,
    List<Map<String, dynamic>>? messages,
  }) {
    return ChatState(
      isSending: isSending ?? this.isSending,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      messages: messages ?? this.messages,
    );
  }
}
