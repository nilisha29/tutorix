import 'package:flutter/material.dart';

class MessageThread {
  const MessageThread({
    required this.tutorId,
    required this.tutorName,
    required this.tutorImage,
    required this.lastMessage,
    required this.updatedAt,
  });

  final String tutorId;
  final String tutorName;
  final String tutorImage;
  final String lastMessage;
  final DateTime updatedAt;
}

class MessageThreadsStore {
  static final ValueNotifier<List<MessageThread>> threads =
      ValueNotifier<List<MessageThread>>(<MessageThread>[]);

  static void upsertThread({
    required String tutorId,
    required String tutorName,
    required String tutorImage,
    required String lastMessage,
  }) {
    final list = List<MessageThread>.from(threads.value);
    final index = list.indexWhere((item) => item.tutorId == tutorId);

    final item = MessageThread(
      tutorId: tutorId,
      tutorName: tutorName,
      tutorImage: tutorImage,
      lastMessage: lastMessage,
      updatedAt: DateTime.now(),
    );

    if (index >= 0) {
      list.removeAt(index);
    }
    list.insert(0, item);
    threads.value = list;
  }
}
