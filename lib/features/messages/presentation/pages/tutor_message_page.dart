import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/api/api_client.dart';
import 'package:tutorix/core/services/storage/user_session_service.dart';
import 'package:tutorix/features/messages/presentation/state/message_threads_store.dart';

class TutorMessagePage extends ConsumerStatefulWidget {
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
  ConsumerState<TutorMessagePage> createState() => _TutorMessagePageState();
}

class _TutorMessagePageState extends ConsumerState<TutorMessagePage> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = <_ChatMessage>[];

  bool _loading = false;
  bool _sending = false;

  String _asId(dynamic raw) {
    if (raw is Map) {
      final map = Map<String, dynamic>.from(raw as Map);
      return (map['_id'] ?? map['id'] ?? '').toString().trim();
    }
    return (raw ?? '').toString().trim();
  }

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() => _loading = true);
    final apiClient = ref.read(apiClientProvider);

    final endpointCandidates = <_EndpointAttempt>[
      _EndpointAttempt(path: '/messages/thread/${widget.tutorId}'),
      _EndpointAttempt(path: '/messages/conversation/${widget.tutorId}'),
      _EndpointAttempt(path: '/messages/student', query: {'tutorId': widget.tutorId}),
      _EndpointAttempt(path: '/messages/my', query: {'tutorId': widget.tutorId}),
      _EndpointAttempt(path: '/messages/tutor', query: {'studentId': widget.tutorId}),
      _EndpointAttempt(path: '/messages/tutor'),
      _EndpointAttempt(path: '/messages'),
    ];

    try {
      for (final endpoint in endpointCandidates) {
        try {
          final response = await apiClient.get(
            endpoint.path,
            queryParameters: endpoint.query,
          );
          final rows = _extractList(response.data);
          final currentUserId = ref.read(userSessionServiceProvider).getUserId() ?? '';

          final parsed = rows
              .map((item) => _toChatMessage(item, currentUserId, widget.tutorId))
              .whereType<_ChatMessage>()
              .toList()
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

          if (!mounted) return;
          setState(() {
            _messages
              ..clear()
              ..addAll(parsed);
          });

          if (parsed.isNotEmpty) {
            MessageThreadsStore.upsertThread(
              tutorId: widget.tutorId,
              tutorName: widget.tutorName,
              tutorImage: widget.tutorImage,
              lastMessage: parsed.last.text,
            );
          }
          return;
        } on DioException catch (e) {
          final code = e.response?.statusCode ?? 0;
          if (code == 404 || code == 400) {
            continue;
          }
          rethrow;
        }
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load messages from backend')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);

    final apiClient = ref.read(apiClientProvider);
    final payload = {
      'tutorId': widget.tutorId,
      'content': text,
    };

    final endpointCandidates = <String>['/messages', '/message'];

    try {
      for (final endpoint in endpointCandidates) {
        try {
          await apiClient.post(endpoint, data: payload);

          if (!mounted) return;
          setState(() {
            _messages.add(
              _ChatMessage(
                id: null,
                text: text,
                isMine: true,
                createdAt: DateTime.now(),
                peerId: widget.tutorId,
              ),
            );
            _controller.clear();
          });

          MessageThreadsStore.upsertThread(
            tutorId: widget.tutorId,
            tutorName: widget.tutorName,
            tutorImage: widget.tutorImage,
            lastMessage: text,
          );
          return;
        } on DioException catch (e) {
          final code = e.response?.statusCode ?? 0;
          if (code == 404 || code == 400) {
            continue;
          }
          rethrow;
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send message')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send message')),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  List<dynamic> _extractList(dynamic raw) {
    if (raw is Map && raw['data'] is List) return raw['data'] as List<dynamic>;
    if (raw is List) return raw;
    return const [];
  }

  _ChatMessage? _toChatMessage(dynamic item, String currentUserId, String peerUserId) {
    if (item is! Map) return null;
    final map = Map<String, dynamic>.from(item as Map);

    final text = (map['content'] ?? map['message'] ?? '').toString();
    if (text.trim().isEmpty) return null;

    final createdAt =
        DateTime.tryParse((map['createdAt'] ?? map['updatedAt'] ?? '').toString()) ??
            DateTime.now();

    final messageId = (map['_id'] ?? map['id'] ?? '').toString().trim();

    final studentId = _asId(map['studentId']);
    final tutorId = _asId(map['tutorId']);
    final senderId = _asId(map['senderId']);
    final receiverId = _asId(map['receiverId']);
    final senderType = (map['senderType'] ?? map['senderRole'] ?? map['role'] ?? '')
      .toString()
      .toLowerCase()
      .trim();

    final participants = <String>{
      studentId.trim(),
      tutorId.trim(),
    }..removeWhere((v) => v.isEmpty);

    if (peerUserId.trim().isNotEmpty) {
      if (currentUserId.trim().isNotEmpty) {
        final needed = <String>{currentUserId.trim(), peerUserId.trim()};
        if (!participants.containsAll(needed)) {
          return null;
        }
      } else if (!participants.contains(peerUserId.trim())) {
        return null;
      }
    }

    bool isMine;
    if (currentUserId.trim().isNotEmpty) {
      if (senderId.trim().isNotEmpty) {
        isMine = senderId.trim() == currentUserId.trim();
      } else if (receiverId.trim().isNotEmpty) {
        isMine = receiverId.trim() != currentUserId.trim();
      } else {
        isMine = studentId.trim() == currentUserId.trim();
      }
    } else {
      if (senderType.isNotEmpty) {
        isMine = !(senderType.contains('tutor') || senderType.contains('teacher'));
      } else if (senderId.isNotEmpty) {
        isMine = senderId != peerUserId.trim();
      } else {
        isMine = false;
      }
    }

    final peerId = currentUserId.trim().isNotEmpty
        ? (studentId.trim() == currentUserId.trim() ? tutorId : studentId)
        : (studentId.trim() == peerUserId.trim() ? tutorId : studentId);

    return _ChatMessage(
      id: messageId.isEmpty ? null : messageId,
      text: text,
      isMine: isMine,
      createdAt: createdAt,
      peerId: peerId,
    );
  }

  Future<void> _deleteMessage(int index) async {
    final message = _messages[index];
    if (message.id == null || message.id!.isEmpty) {
      setState(() => _messages.removeAt(index));
      return;
    }

    final apiClient = ref.read(apiClientProvider);
    final endpointCandidates = <String>[
      '/messages/${message.id}',
      '/message/${message.id}',
    ];

    for (final endpoint in endpointCandidates) {
      try {
        await apiClient.delete(endpoint);
        if (!mounted) return;
        setState(() => _messages.removeAt(index));
        return;
      } on DioException catch (e) {
        final code = e.response?.statusCode ?? 0;
        if (code == 404 || code == 400) {
          continue;
        }
        break;
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Failed to delete message')),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mineBubble = isDark ? const Color(0xFF2F7BFF) : const Color(0xFF2D7CFF);
    final peerBubble = isDark ? const Color(0xFF22252B) : const Color(0xFFF1F3F6);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: widget.tutorImage.isNotEmpty
                  ? NetworkImage(widget.tutorImage)
                  : null,
              child: widget.tutorImage.isEmpty ? const Icon(Icons.person, size: 18) : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.tutorName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'refresh') {
                  _loadMessages();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'refresh', child: Text('Refresh')),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment:
                              msg.isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!msg.isMine)
                              const Padding(
                                padding: EdgeInsets.only(right: 6, bottom: 2),
                                child: CircleAvatar(radius: 10, child: Icon(Icons.person, size: 12)),
                              ),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 290),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: msg.isMine ? mineBubble : peerBubble,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft: Radius.circular(msg.isMine ? 16 : 4),
                                    bottomRight: Radius.circular(msg.isMine ? 4 : 16),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      msg.text,
                                      style: TextStyle(
                                        color: msg.isMine
                                            ? Colors.white
                                            : (isDark ? Colors.white : Colors.black87),
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _formatTime(msg.createdAt),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: msg.isMine
                                                ? Colors.white70
                                                : (isDark ? Colors.white70 : Colors.black54),
                                          ),
                                        ),
                                        if (msg.isMine)
                                          PopupMenuButton<String>(
                                            padding: EdgeInsets.zero,
                                            icon: Icon(
                                              Icons.more_vert,
                                              size: 16,
                                              color: Colors.white70,
                                            ),
                                            onSelected: (value) {
                                              if (value == 'delete') {
                                                _deleteMessage(index);
                                              }
                                            },
                                            itemBuilder: (_) => const [
                                              PopupMenuItem(
                                                value: 'delete',
                                                child: Text('Delete message'),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Message...',
                        filled: true,
                        fillColor: isDark ? const Color(0xFF141414) : const Color(0xFFF1F2F4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: _sending ? null : _sendMessage,
                    style: IconButton.styleFrom(
                      backgroundColor: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFE8F0FF),
                    ),
                    icon: _sending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            Icons.send_rounded,
                            color: isDark ? Colors.white : const Color(0xFF2D7CFF),
                          ),
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
  const _ChatMessage({
    required this.id,
    required this.text,
    required this.isMine,
    required this.createdAt,
    required this.peerId,
  });

  final String? id;
  final String text;
  final bool isMine;
  final DateTime createdAt;
  final String peerId;
}

class _EndpointAttempt {
  const _EndpointAttempt({required this.path, this.query});

  final String path;
  final Map<String, dynamic>? query;
}
