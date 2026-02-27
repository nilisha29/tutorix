import 'package:flutter/material.dart';
import 'package:tutorix/features/dashboard/presentation/pages/message_threads_store.dart';
import 'package:tutorix/features/dashboard/presentation/pages/tutor_message_page.dart';

class MessagesInboxPage extends StatelessWidget {
  const MessagesInboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: true,
      ),
      body: ValueListenableBuilder<List<MessageThread>>(
        valueListenable: MessageThreadsStore.threads,
        builder: (context, threads, _) {
          if (threads.isEmpty) {
            return const Center(child: Text('No messages yet'));
          }

          return ListView.builder(
            itemCount: threads.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final thread = threads[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        thread.tutorImage.isNotEmpty ? NetworkImage(thread.tutorImage) : null,
                    child: thread.tutorImage.isEmpty ? const Icon(Icons.person) : null,
                  ),
                  title: Text(thread.tutorName),
                  subtitle: Text(
                    thread.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TutorMessagePage(
                          tutorId: thread.tutorId,
                          tutorName: thread.tutorName,
                          tutorImage: thread.tutorImage,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
