abstract interface class IMessagesDatasource {
  Future<List<Map<String, dynamic>>> getConversations();

  Future<Map<String, dynamic>> sendMessage({
    required String conversationId,
    required String content,
  });
}
