import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/features/messages/data/datasources/messages_datasource.dart';

final messagesLocalDatasourceProvider = Provider<IMessagesDatasource>((ref) {
  return MessagesLocalDatasource();
});

class MessagesLocalDatasource implements IMessagesDatasource {
  final List<Map<String, dynamic>> _conversations = <Map<String, dynamic>>[];

  @override
  Future<List<Map<String, dynamic>>> getConversations() async {
    return _conversations;
  }

  @override
  Future<Map<String, dynamic>> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    final message = <String, dynamic>{
      'conversationId': conversationId,
      'content': content,
      'status': 'cached',
    };
    _conversations.add(message);
    return message;
  }
}
