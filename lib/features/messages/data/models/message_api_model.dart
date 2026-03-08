class MessageApiModel {
  const MessageApiModel({
    required this.conversationId,
    required this.content,
  });

  final String conversationId;
  final String content;

  factory MessageApiModel.fromJson(Map<String, dynamic> json) {
    return MessageApiModel(
      conversationId: (json['conversationId'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'conversationId': conversationId,
      'content': content,
    };
  }
}
