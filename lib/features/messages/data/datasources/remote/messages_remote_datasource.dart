import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/api/api_client.dart';
import 'package:tutorix/features/messages/data/datasources/messages_datasource.dart';

final messagesRemoteDatasourceProvider = Provider<IMessagesDatasource>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return MessagesRemoteDatasource(apiClient: apiClient);
});

class MessagesRemoteDatasource implements IMessagesDatasource {
  MessagesRemoteDatasource({required ApiClient apiClient});

  @override
  Future<List<Map<String, dynamic>>> getConversations() async {
    return <Map<String, dynamic>>[];
  }

  @override
  Future<Map<String, dynamic>> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    return <String, dynamic>{
      'conversationId': conversationId,
      'content': content,
      'status': 'sent',
    };
  }
}
