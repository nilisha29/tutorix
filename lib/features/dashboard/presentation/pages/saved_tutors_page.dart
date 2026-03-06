import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:tutorix/core/api/api_client.dart';
import 'package:tutorix/core/api/api_endpoints.dart';
import 'package:tutorix/features/dashboard/presentation/pages/saved_tutor_store.dart';
import 'package:tutorix/features/dashboard/presentation/pages/tutor_profile_page.dart';

class SavedTutorsPage extends ConsumerStatefulWidget {
  const SavedTutorsPage({super.key});

  @override
  ConsumerState<SavedTutorsPage> createState() => _SavedTutorsPageState();
}

class _SavedTutorsPageState extends ConsumerState<SavedTutorsPage> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchSavedTutors();
  }

  Future<void> _fetchSavedTutors() async {
    setState(() => _loading = true);
    final apiClient = ref.read(apiClientProvider);

    final endpointCandidates = <String>[
      '/saved-tutors/my',
      '/savedtutors/my',
      '/saved-tutor/my',
    ];

    try {
      for (final endpoint in endpointCandidates) {
        try {
          final response = await apiClient.get(endpoint);
          final list = _extractList(response.data);
          final tutors = list.map(_toSavedTutor).whereType<SavedTutor>().toList();
          SavedTutorStore.setSavedTutors(tutors);
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
        const SnackBar(content: Text('Failed to load saved tutors from backend')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<dynamic> _extractList(dynamic raw) {
    if (raw is Map && raw['data'] is List) {
      return raw['data'] as List<dynamic>;
    }
    if (raw is List) {
      return raw;
    }
    return const [];
  }

  SavedTutor? _toSavedTutor(dynamic item) {
    if (item is! Map) return null;
    final map = Map<String, dynamic>.from(item as Map);
    final tutorRaw = map['tutorId'];
    final tutor = tutorRaw is Map ? Map<String, dynamic>.from(tutorRaw as Map) : map;

    final id = (tutor['_id'] ?? tutor['id'] ?? map['tutorId'] ?? '').toString();
    if (id.trim().isEmpty) return null;

    final ratingRaw = tutor['rating'] ?? tutor['averageRating'] ?? 0;
    final rating = ratingRaw is num
        ? ratingRaw.toStringAsFixed(1)
        : (double.tryParse(ratingRaw.toString())?.toStringAsFixed(1) ?? '0.0');

    final priceRaw = tutor['pricePerHour'] ?? tutor['price'] ?? '';
    final price = priceRaw.toString().trim().isEmpty
        ? 'N/A'
        : 'Rs ${priceRaw.toString()}';

    return SavedTutor(
      tutorId: id,
      name: (tutor['fullName'] ?? tutor['name'] ?? tutor['username'] ?? 'Tutor').toString(),
      subject: (tutor['subject'] ?? 'General').toString(),
      rating: rating,
      imageUrl: _normalizeImageUrl((tutor['profileImage'] ?? tutor['avatar'] ?? '').toString()),
      price: price,
    );
  }

  String _normalizeImageUrl(String value) {
    final url = value.trim();
    if (url.isEmpty) return '';
    if (url.startsWith('http://localhost:') ||
        url.startsWith('https://localhost:') ||
        url.startsWith('http://127.0.0.1:') ||
        url.startsWith('https://127.0.0.1:')) {
      final uri = Uri.tryParse(url);
      if (uri != null) {
        final base = Uri.parse(ApiEndpoints.serverUrl);
        return Uri(
          scheme: base.scheme,
          host: base.host,
          port: base.port,
          path: uri.path,
          query: uri.query.isEmpty ? null : uri.query,
        ).toString();
      }
      return '';
    }
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('/')) return '${ApiEndpoints.mediaServerUrl}$url';
    return '${ApiEndpoints.mediaServerUrl}/$url';
  }

  Future<void> _removeSavedTutor(SavedTutor tutor) async {
    final apiClient = ref.read(apiClientProvider);
    final endpointCandidates = <String>[
      '/saved-tutors/${tutor.tutorId}',
      '/savedtutors/${tutor.tutorId}',
      '/saved-tutor/${tutor.tutorId}',
    ];

    for (final endpoint in endpointCandidates) {
      try {
        await apiClient.delete(endpoint);
        SavedTutorStore.removeByTutorId(tutor.tutorId);
        return;
      } on DioException catch (e) {
        final code = e.response?.statusCode ?? 0;
        if (code == 404 || code == 400) {
          continue;
        }
        rethrow;
      }
    }

    SavedTutorStore.removeByTutorId(tutor.tutorId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Tutors')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ValueListenableBuilder<List<SavedTutor>>(
        valueListenable: SavedTutorStore.savedTutors,
        builder: (context, tutors, _) {
          if (tutors.isEmpty) {
            return const Center(child: Text('No saved tutors yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: tutors.length,
            itemBuilder: (context, index) {
              final tutor = tutors[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF111111)
                      : Colors.white,
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white24
                        : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundImage:
                              tutor.imageUrl.isNotEmpty ? NetworkImage(tutor.imageUrl) : null,
                          child: tutor.imageUrl.isEmpty ? const Icon(Icons.person) : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tutor.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tutor.subject,
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white70
                                      : Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('Rating: ${tutor.rating}  •  ${tutor.price}'),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.bookmark, color: Color(0xFFF4C430)),
                          onPressed: () => _removeSavedTutor(tutor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TutorProfilePage(
                                    tutorId: tutor.tutorId,
                                    initialName: tutor.name,
                                    initialSubject: tutor.subject,
                                    initialRating: tutor.rating,
                                    initialProfileImage: tutor.imageUrl,
                                    initialPrice: tutor.price,
                                    initialAbout: 'No tutor description provided yet.',
                                    initialExperienceYears: '0',
                                    initialSubjects: <String>[tutor.subject],
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.person_outline),
                            label: const Text('View Profile'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
