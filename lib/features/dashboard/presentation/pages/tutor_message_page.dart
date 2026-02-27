import 'package:flutter/material.dart';
import 'package:tutorix/features/dashboard/presentation/pages/message_threads_store.dart';

class TutorMessagePage extends StatefulWidget {
  const TutorMessagePage({
    super.key,
    required this.tutorId,
    required this.tutorName,
    this.tutorImage = '',
  });

  final String tutorId;
  final String tutorName;
  final String tutorImage;

  @override
  State<TutorMessagePage> createState() => _TutorMessagePageState();
}

class _TutorMessagePageState extends State<TutorMessagePage> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = <_ChatMessage>[
    const _ChatMessage(text: 'Hello! I want to know about your class timing.', isMine: true),
    const _ChatMessage(text: 'Sure, I am available in the evening on weekdays.', isMine: false),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isMine: true));
      _controller.clear();
    });

    MessageThreadsStore.upsertThread(
      tutorId: widget.tutorId,
      tutorName: widget.tutorName,
      tutorImage: widget.tutorImage,
      lastMessage: text,
    );
  }

  @override
  void initState() {
    super.initState();
    MessageThreadsStore.upsertThread(
      tutorId: widget.tutorId,
      tutorName: widget.tutorName,
      tutorImage: widget.tutorImage,
      lastMessage: 'Started conversation',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Message ${widget.tutorName}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg.isMine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: msg.isMine ? const Color(0xFFD5EBFF) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(msg.text),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage({required this.text, required this.isMine});

  final String text;
  final bool isMine;
}
