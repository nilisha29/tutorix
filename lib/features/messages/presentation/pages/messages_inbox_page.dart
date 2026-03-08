import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:tutorix/core/api/api_client.dart';
import 'package:tutorix/core/api/api_endpoints.dart';
import 'package:tutorix/core/services/storage/user_session_service.dart';
import 'package:tutorix/features/messages/presentation/state/message_threads_store.dart';
import 'package:tutorix/features/messages/presentation/pages/tutor_message_page.dart';

class MessagesInboxPage extends ConsumerStatefulWidget {
  const MessagesInboxPage({super.key});

  @override
  ConsumerState<MessagesInboxPage> createState() => _MessagesInboxPageState();
}

class _MessagesInboxPageState extends ConsumerState<MessagesInboxPage> {
  static const double _shakeThreshold = 22;
  static const Duration _shakeCooldown = Duration(seconds: 2);

  bool _loading = false;
  String _query = '';
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  double? _lastMagnitude;
  DateTime _lastShakeAt = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    _fetchThreads();
    _startShakeListener();
  }

  void _startShakeListener() {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      final previous = _lastMagnitude;
      _lastMagnitude = magnitude;
      if (previous == null) return;

      final delta = (magnitude - previous).abs();
      final now = DateTime.now();
      final cooldownPassed = now.difference(_lastShakeAt) > _shakeCooldown;

      if (delta >= _shakeThreshold && cooldownPassed && !_loading) {
        _lastShakeAt = now;
        _fetchThreads();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Shake detected: reloading messages')),
          );
        }
      }
    });
  }

  Future<void> _fetchThreads() async {
    setState(() => _loading = true);
    final apiClient = ref.read(apiClientProvider);

    final endpointCandidates = <String>[
      '/messages/my',
      '/messages/student',
      '/messages/tutor',
      '/messages',
    ];

    try {
      for (final endpoint in endpointCandidates) {
        try {
          final response = await apiClient.get(endpoint);
          final rows = _extractList(response.data);
          final byPeer = <String, MessageThread>{};

          for (final item in rows) {
            final thread = _toThread(item);
            if (thread == null) continue;
            final existing = byPeer[thread.tutorId];
            if (existing == null || thread.updatedAt.isAfter(existing.updatedAt)) {
              byPeer[thread.tutorId] = thread;
            }
          }

          final list = byPeer.values.toList()
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

          MessageThreadsStore.setThreads(list);
          if (!mounted) return;
          setState(() => _loading = false);
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

  List<dynamic> _extractList(dynamic raw) {
    if (raw is Map && raw['data'] is List) return raw['data'] as List<dynamic>;
    if (raw is List) return raw;
    return const [];
  }

  MessageThread? _toThread(dynamic item) {
    if (item is! Map) return null;
    final map = Map<String, dynamic>.from(item as Map);

    final currentUserId = ref.read(userSessionServiceProvider).getUserId() ?? '';
    final studentRaw = map['studentId'];
    final tutorRaw = map['tutorId'];

    final studentMap = studentRaw is Map ? Map<String, dynamic>.from(studentRaw as Map) : null;
    final tutorMap = tutorRaw is Map ? Map<String, dynamic>.from(tutorRaw as Map) : null;

    final studentId = studentMap != null
        ? (studentMap['_id'] ?? studentMap['id'] ?? '').toString()
        : (studentRaw?.toString() ?? '');

    final tutorId = tutorMap != null
        ? (tutorMap['_id'] ?? tutorMap['id'] ?? '').toString()
        : (tutorRaw?.toString() ?? '');

    final isCurrentTutor = currentUserId.isNotEmpty && tutorId == currentUserId;
    final peerMap = isCurrentTutor ? studentMap : tutorMap;
    final peerId = (isCurrentTutor ? studentId : tutorId).trim();
    if (peerId.isEmpty) return null;

    final peerName =
        (peerMap?['fullName'] ?? peerMap?['name'] ?? peerMap?['username'] ?? 'User')
            .toString();
    final peerImage =
        _normalizeImageUrl((peerMap?['profileImage'] ?? peerMap?['avatar'] ?? '').toString());

    final createdAt = DateTime.tryParse(
          (map['createdAt'] ?? map['updatedAt'] ?? '').toString(),
        ) ??
        DateTime.now();

    final lastMessage =
        (map['content'] ?? map['message'] ?? map['lastMessage'] ?? '').toString();

    return MessageThread(
      tutorId: peerId,
      tutorName: peerName,
      tutorImage: peerImage,
      lastMessage: lastMessage,
      updatedAt: createdAt,
    );
  }

  String _normalizeImageUrl(String value) {
    final url = value.trim();
    if (url.isEmpty) return '';
    if (url.startsWith('http://localhost:')) {
      final uri = Uri.tryParse(url);
      if (uri != null) {
        final base = Uri.parse(ApiEndpoints.serverUrl);
        return Uri(
          scheme: base.scheme,
          host: base.host,
          port: base.port,
          path: uri.path,
        ).toString();
      }
      return '';
    }
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('/')) return '${ApiEndpoints.mediaServerUrl}$url';
    return '${ApiEndpoints.mediaServerUrl}/$url';
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
  void dispose() {
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final username = ref.read(userSessionServiceProvider).getUserName() ?? 'messages';

    return Scaffold(
      appBar: AppBar(
        title: Text(username),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ValueListenableBuilder<List<MessageThread>>(
              valueListenable: MessageThreadsStore.threads,
              builder: (context, threads, _) {
                final filtered = threads
                    .where((t) =>
                        _query.isEmpty || t.tutorName.toLowerCase().contains(_query.toLowerCase()))
                    .toList();

                return RefreshIndicator(
                  onRefresh: _fetchThreads,
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [
                      TextField(
                        onChanged: (v) => setState(() => _query = v.trim()),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: isDark ? const Color(0xFF141414) : const Color(0xFFF1F2F4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 90,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final t = filtered[index];
                            return SizedBox(
                              width: 72,
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundImage: t.tutorImage.isNotEmpty
                                        ? NetworkImage(t.tutorImage)
                                        : null,
                                    child: t.tutorImage.isEmpty
                                        ? const Icon(Icons.person)
                                        : null,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    t.tutorName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Messages',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 10),
                      if (filtered.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 40),
                          child: Center(child: Text('No messages yet')),
                        )
                      else
                        ...filtered.map((thread) {
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 6),
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundImage: thread.tutorImage.isNotEmpty
                                  ? NetworkImage(thread.tutorImage)
                                  : null,
                              child: thread.tutorImage.isEmpty
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(
                              thread.tutorName,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              thread.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              _formatTime(thread.updatedAt),
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                                fontSize: 12,
                              ),
                            ),
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
                          );
                        }),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
