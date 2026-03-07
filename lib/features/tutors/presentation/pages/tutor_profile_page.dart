import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/api/api_client.dart';
import 'package:tutorix/core/api/api_endpoints.dart';
import 'package:tutorix/features/tutors/presentation/pages/book_tutor_page.dart';
import 'package:tutorix/features/saved_tutors/presentation/state/saved_tutor_store.dart';
import 'package:tutorix/features/messages/presentation/pages/tutor_message_page.dart';

class TutorProfilePage extends ConsumerStatefulWidget {
  const TutorProfilePage({
    super.key,
    required this.tutorId,
    required this.initialName,
    required this.initialSubject,
    required this.initialRating,
    required this.initialProfileImage,
    required this.initialPrice,
    required this.initialAbout,
    required this.initialExperienceYears,
    required this.initialSubjects,
  });

  final String tutorId;
  final String initialName;
  final String initialSubject;
  final String initialRating;
  final String initialProfileImage;
  final String initialPrice;
  final String initialAbout;
  final String initialExperienceYears;
  final List<String> initialSubjects;

  @override
  ConsumerState<TutorProfilePage> createState() => _TutorProfilePageState();
}

class _TutorProfilePageState extends ConsumerState<TutorProfilePage> {
  bool _isLoading = true;
  String? _error;

  late String _name;
  late String _subject;
  late String _rating;
  late String _profileImage;
  late String _price;
  late String _about;
  late String _experienceYears;
  late List<String> _subjects;
  List<String> _availabilitySlots = const [];
  List<_TutorReview> _reviews = [];
  Map<String, String> _extraFields = {};

  final TextEditingController _reviewController = TextEditingController();
  int _selectedRating = 5;
  bool _submittingReview = false;
  bool _togglingSaved = false;

  @override
  void initState() {
    super.initState();
    _name = widget.initialName;
    _subject = widget.initialSubject;
    _rating = widget.initialRating;
    _profileImage = widget.initialProfileImage;
    _price = widget.initialPrice;
    _about = widget.initialAbout;
    _experienceYears = widget.initialExperienceYears;
    _subjects = widget.initialSubjects;
    _fetchTutorProfile();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _fetchTutorProfile() async {
    if (widget.tutorId.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final apiClient = ref.read(apiClientProvider);
    final candidatePaths = <String>[
      '/tutors/${widget.tutorId}',
      '/users/${widget.tutorId}',
      '/users/profile/${widget.tutorId}',
      '/teacher/tutors/${widget.tutorId}',
      '/auth/tutors/${widget.tutorId}',
    ];

    DioException? lastError;

    for (final path in candidatePaths) {
      try {
        final response = await apiClient.get(path);
        final data = _extractMap(response.data);

        if (!mounted) return;

        _hydrateFromData(data);
        await _fetchReviewsFromBackend();
        setState(() {
          _isLoading = false;
          _error = null;
        });
        return;
      } on DioException catch (e) {
        if (e.response?.statusCode == 404 || e.response?.statusCode == 400) {
          lastError = e;
          continue;
        }
        rethrow;
      }
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _error = lastError?.message ?? 'Unable to load tutor profile';
    });
  }

  Map<String, dynamic> _extractMap(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      if (raw['data'] is Map) {
        return _safeMap(raw['data'] as Map);
      }
      return raw;
    }
    if (raw is Map) {
      return _safeMap(raw);
    }
    return <String, dynamic>{};
  }

  Map<String, dynamic> _safeMap(Map raw) {
    final map = <String, dynamic>{};
    raw.forEach((key, value) {
      if (key != null) {
        map[key.toString()] = value;
      }
    });
    return map;
  }

  void _hydrateFromData(Map<String, dynamic> data) {
    final aboutText = (data['bio'] ?? data['about'] ?? '').toString();
    final ratingRaw = data['averageRating'] ?? data['rating'] ?? _rating;
    final ratingNum = ratingRaw is num
        ? ratingRaw.toDouble()
        : double.tryParse(ratingRaw.toString()) ?? 4.8;

    final priceRaw = data['hourlyRate'] ?? data['pricePerHour'] ?? data['price'];
    final priceNum = priceRaw is num
        ? priceRaw.toDouble()
        : double.tryParse(priceRaw?.toString() ?? '') ?? 50;

    final expRaw =
        data['experienceYears'] ?? data['experience'] ?? data['yearsOfExperience'];
    final expNum = expRaw is num
        ? expRaw.toInt()
        : int.tryParse(expRaw?.toString() ?? '') ?? 5;

    final subjectList = <String>[];
    final subjects = data['subjects'];
    final subjectSingle = data['subject'];
    final languages = data['languages'];
    final tags = data['tags'];

    if (subjects is List && subjects.isNotEmpty) {
      subjectList.addAll(subjects.map((e) => e.toString()));
    } else if (subjectSingle != null && subjectSingle.toString().trim().isNotEmpty) {
      subjectList.add(subjectSingle.toString().trim());
    } else if (tags is List && tags.isNotEmpty) {
      subjectList.addAll(tags.map((e) => e.toString()));
    } else if (languages is List && languages.isNotEmpty) {
      subjectList.addAll(languages.map((e) => e.toString()));
    }

    final reviewsRaw = data['reviews'];
    final reviews = <_TutorReview>[];
    if (reviewsRaw is List) {
      for (final item in reviewsRaw) {
        if (item is Map) {
          final map = _safeMap(item);
          reviews.add(
            _TutorReview(
              reviewerName: (map['reviewerName'] ?? map['name'] ?? 'User').toString(),
              comment: (map['comment'] ?? map['review'] ?? '').toString(),
              rating: ((map['rating'] ?? 5) is num)
                  ? (map['rating'] as num).toDouble()
                  : double.tryParse((map['rating'] ?? '5').toString()) ?? 5,
            ),
          );
        }
      }
    }

    final slots = _extractAvailabilitySlots(data);

    final image = (data['profileImage'] ?? data['avatar'] ?? '').toString();

    final languageText = languages is List
        ? languages.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).join(', ')
        : (data['language'] ?? '').toString();
    final tagText = tags is List
        ? tags.map((e) => e.toString()).where((e) => e.trim().isNotEmpty).join(', ')
        : '';
    final educationText = (data['education'] ?? data['degree'] ?? data['qualification'] ?? '')
        .toString();

    final extras = <String, String>{
      if (educationText.isNotEmpty) 'Education': educationText,
      if (tagText.isNotEmpty) 'Tags': tagText,
      if (languageText.isNotEmpty) 'Languages': languageText,
      if ((data['email'] ?? '').toString().isNotEmpty)
        'Email': (data['email']).toString(),
      if ((data['phoneNumber'] ?? '').toString().isNotEmpty)
        'Phone': (data['phoneNumber']).toString(),
      if ((data['address'] ?? '').toString().isNotEmpty)
        'Address': (data['address']).toString(),
    };

    _name = (data['fullName'] ?? data['name'] ?? _name).toString();
    _subject = subjectList.isNotEmpty
        ? subjectList.join(', ')
        : (data['headline'] ?? data['title'] ?? _subject).toString();
    _rating = ratingNum.toStringAsFixed(1);
    _profileImage = _normalizeImageUrl(image.isNotEmpty ? image : _profileImage);
    _price = 'Rs. ${priceNum.toStringAsFixed(0)}/hr';
    _about = aboutText.isNotEmpty ? aboutText : (_about.isNotEmpty ? _about : 'No bio available');
    _experienceYears = '$expNum Years';
    _subjects = subjectList.isNotEmpty ? subjectList : _subjects;
    _availabilitySlots = slots;
    _reviews = reviews;
    _extraFields = extras;
  }

  List<String> _extractAvailabilitySlots(Map<String, dynamic> data) {
    final slotSet = <String>{};
    final candidates = [
      data['availabilitySlots'],
      data['availability'],
      data['availabilitySlot'],
      data['slots'],
      data['schedule'],
      data['schedules'],
    ];

    for (final candidate in candidates) {
      _collectSlots(candidate, slotSet);
    }

    return slotSet.toList();
  }

  void _collectSlots(dynamic value, Set<String> bucket, {String? prefix}) {
    if (value == null) return;

    if (value is String) {
      final normalized = value.trim();
      if (normalized.isNotEmpty) {
        bucket.add(prefix == null ? normalized : '$prefix: $normalized');
      }
      return;
    }

    if (value is List) {
      for (final item in value) {
        _collectSlots(item, bucket, prefix: prefix);
      }
      return;
    }

    if (value is Map) {
      final map = _safeMap(value);
      final day = (map['day'] ?? map['date'] ?? map['weekday'] ?? prefix ?? '')
          .toString()
          .trim();

      final start = (map['startTime'] ?? map['start'] ?? map['from'] ?? '')
          .toString()
          .trim();
      final end = (map['endTime'] ?? map['end'] ?? map['to'] ?? '')
          .toString()
          .trim();

      if (start.isNotEmpty && end.isNotEmpty) {
        if (day.isNotEmpty) {
          bucket.add('$day: $start - $end');
        } else {
          bucket.add('$start - $end');
        }
      } else if (start.isNotEmpty) {
        if (day.isNotEmpty) {
          bucket.add('$day: $start');
        } else {
          bucket.add(start);
        }
      }

      if (map['slots'] != null) {
        _collectSlots(map['slots'], bucket, prefix: day.isEmpty ? prefix : day);
      }
      if (map['times'] != null) {
        _collectSlots(map['times'], bucket, prefix: day.isEmpty ? prefix : day);
      }

      for (final entry in map.entries) {
        final key = entry.key.toString();
        final keyLower = key.toLowerCase();

        if (key == 'day' ||
            key == 'date' ||
            key == 'weekday' ||
            key == 'startTime' ||
            key == 'start' ||
            key == 'from' ||
            key == 'endTime' ||
            key == 'end' ||
            key == 'to' ||
            key == 'slots' ||
            key == 'times' ||
            keyLower == 'id' ||
            keyLower == '_id' ||
            keyLower == 'userid' ||
            keyLower == 'user_id' ||
            keyLower == 'tutorid' ||
            keyLower == 'tutor_id' ||
            keyLower == 'teacherid' ||
            keyLower == 'teacher_id' ||
            keyLower == 'createdat' ||
            keyLower == 'updatedat' ||
            keyLower == '__v') {
          continue;
        }

        if (entry.value is List || entry.value is Map || entry.value is String) {
          _collectSlots(entry.value, bucket, prefix: key);
        }
      }
    }
  }

  String _normalizeImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
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
    if (url.startsWith('http')) return url;
    return '${ApiEndpoints.mediaServerUrl}$url';
  }

  List<_AvailabilityBlock> _buildAvailabilityBlocks() {
    final grouped = <String, List<String>>{};

    for (final rawSlot in _availabilitySlots) {
      final value = rawSlot.trim();
      if (value.isEmpty) continue;

      final separatorIndex = value.indexOf(':');
      if (separatorIndex <= 0) {
        grouped.putIfAbsent(value, () => <String>[]);
        continue;
      }

      final dayLabel = value.substring(0, separatorIndex).trim();
      final timePart = value.substring(separatorIndex + 1).trim();
      final times = timePart
          .split(RegExp(r'\s*-\s*|\s*,\s*'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final bucket = grouped.putIfAbsent(dayLabel, () => <String>[]);
      for (final time in times) {
        if (!bucket.contains(time)) {
          bucket.add(time);
        }
      }
    }

    bool _isMetaOrIdLabel(String label) {
      final v = label.trim().toLowerCase();
      if (v.isEmpty) return true;
      if (v == 'id' ||
          v == '_id' ||
          v == 'userid' ||
          v == 'tutorid' ||
          v == 'teacherid' ||
          v == 'createdat' ||
          v == 'updatedat' ||
          v == '__v') {
        return true;
      }
      return RegExp(r'^[a-f0-9]{24}$').hasMatch(v);
    }

    return grouped.entries
        .where((entry) => !_isMetaOrIdLabel(entry.key))
        .map((entry) => _AvailabilityBlock(dayLabel: entry.key, times: entry.value))
        .toList();
  }

  Future<void> _fetchReviewsFromBackend() async {
    final apiClient = ref.read(apiClientProvider);
    final endpointCandidates = <_EndpointAttempt>[
      _EndpointAttempt(path: '/tutors/${widget.tutorId}/reviews'),
      _EndpointAttempt(path: '/reviews', query: {'tutorId': widget.tutorId}),
      _EndpointAttempt(path: '/reviews/tutor/${widget.tutorId}'),
    ];

    for (final endpoint in endpointCandidates) {
      try {
        final response = await apiClient.get(
          endpoint.path,
          queryParameters: endpoint.query,
        );
        final rows = _extractList(response.data);
        final parsed = <_TutorReview>[];
        for (final item in rows) {
          if (item is! Map) continue;
          final map = Map<String, dynamic>.from(item as Map);
          final ratingRaw = map['rating'] ?? map['stars'] ?? 0;
          final rating = ratingRaw is num
              ? ratingRaw.toDouble()
              : double.tryParse(ratingRaw.toString()) ?? 0;
          parsed.add(
            _TutorReview(
              reviewerName: (map['reviewerName'] ?? map['name'] ?? map['studentName'] ?? 'User')
                  .toString(),
              comment: (map['comment'] ?? map['review'] ?? map['content'] ?? '').toString(),
              rating: rating,
            ),
          );
        }
        if (parsed.isNotEmpty) {
          _reviews = parsed;
        }
        return;
      } on DioException catch (e) {
        final code = e.response?.statusCode ?? 0;
        if (code == 404 || code == 400) {
          continue;
        }
        return;
      }
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

  Future<void> _submitReview() async {
    final comment = _reviewController.text.trim();
    if (comment.isEmpty) return;

    setState(() {
      _submittingReview = true;
    });

    try {
      final apiClient = ref.read(apiClientProvider);
      final candidateRequests = <Map<String, dynamic>>[
        {
          'path': '/reviews',
          'data': {
            'tutorId': widget.tutorId,
            'rating': _selectedRating,
            'comment': comment,
            'quote': comment,
          },
        },
        {
          'path': '/reviews',
          'data': {
            'teacherId': widget.tutorId,
            'rating': _selectedRating,
            'comment': comment,
            'quote': comment,
          },
        },
        {
          'path': '/reviews',
          'data': {
            'userId': widget.tutorId,
            'rating': _selectedRating,
            'review': comment,
            'quote': comment,
          },
        },
        {
          'path': '/tutors/${widget.tutorId}/reviews',
          'data': {
            'rating': _selectedRating,
            'comment': comment,
            'quote': comment,
          },
        },
      ];

      DioException? lastError;
      bool submitted = false;

      for (final request in candidateRequests) {
        final path = request['path'] as String;
        final data = request['data'];
        try {
          await apiClient.post(path, data: data);
          submitted = true;
          break;
        } on DioException catch (e) {
          lastError = e;
          continue;
        }
      }

      if (!mounted) return;

      if (submitted) {
        setState(() {
          _reviews = [
            _TutorReview(
              reviewerName: 'You',
              comment: comment,
              rating: _selectedRating.toDouble(),
            ),
            ..._reviews,
          ];
          _reviewController.clear();
          _selectedRating = 5;
        });

        await _fetchReviewsFromBackend();
        if (mounted) {
          setState(() {});
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully')),
        );
      } else {
        final statusCode = lastError?.response?.statusCode;
        if (statusCode == 404) {
          setState(() {
            _reviews = [
              _TutorReview(
                reviewerName: 'You',
                comment: comment,
                rating: _selectedRating.toDouble(),
              ),
              ..._reviews,
            ];
            _reviewController.clear();
            _selectedRating = 5;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Backend review endpoint not available. Review added locally.'),
            ),
          );
        } else {
          final responseData = lastError?.response?.data;
          final backendMessage = responseData is Map
              ? responseData['message']?.toString()
              : null;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                backendMessage ?? lastError?.message ?? 'Failed to submit review',
              ),
            ),
          );
        }
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit review')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submittingReview = false;
        });
      }
    }
  }

  Future<void> _toggleSavedTutor() async {
    if (_togglingSaved) return;
    final currentlySaved = SavedTutorStore.isSaved(widget.tutorId);
    setState(() => _togglingSaved = true);

    final apiClient = ref.read(apiClientProvider);
    try {
      if (currentlySaved) {
        final removeCandidates = <String>[
          '/saved-tutors/${widget.tutorId}',
          '/savedtutors/${widget.tutorId}',
          '/saved-tutor/${widget.tutorId}',
        ];

        for (final endpoint in removeCandidates) {
          try {
            await apiClient.delete(endpoint);
            SavedTutorStore.removeByTutorId(widget.tutorId);
            if (mounted) setState(() {});
            return;
          } on DioException catch (e) {
            final code = e.response?.statusCode ?? 0;
            if (code == 404 || code == 400) {
              continue;
            }
            rethrow;
          }
        }

        SavedTutorStore.removeByTutorId(widget.tutorId);
        if (mounted) setState(() {});
        return;
      }

      final saveCandidates = <String>[
        '/saved-tutors',
        '/savedtutors',
        '/saved-tutor',
      ];

      for (final endpoint in saveCandidates) {
        try {
          await apiClient.post(endpoint, data: {'tutorId': widget.tutorId});
          SavedTutorStore.upsert(
            SavedTutor(
              tutorId: widget.tutorId,
              name: _name,
              subject: _subject,
              rating: _rating,
              imageUrl: _profileImage,
              price: _price,
            ),
          );
          if (mounted) setState(() {});
          return;
        } on DioException catch (e) {
          final code = e.response?.statusCode ?? 0;
          if (code == 404 || code == 400) {
            continue;
          }
          rethrow;
        }
      }

      SavedTutorStore.upsert(
        SavedTutor(
          tutorId: widget.tutorId,
          name: _name,
          subject: _subject,
          rating: _rating,
          imageUrl: _profileImage,
          price: _price,
        ),
      );
      if (mounted) setState(() {});
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update saved tutor on backend')),
      );
    } finally {
      if (mounted) {
        setState(() => _togglingSaved = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaved = SavedTutorStore.isSaved(widget.tutorId);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF3F6F9),
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : const Color(0xFFF3F6F9),
        elevation: 0,
        foregroundColor: isDark ? Colors.white : Colors.black,
        centerTitle: true,
        title: const Text(
          'Tutor Profile',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFE8F6FC), Colors.white],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage:
                              _profileImage.isNotEmpty ? NetworkImage(_profileImage) : null,
                          child: _profileImage.isEmpty
                              ? const Icon(Icons.person, size: 36, color: Colors.white)
                              : null,
                          onBackgroundImageError:
                              _profileImage.isNotEmpty ? (_, __) {} : null,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _name,
                          style: const TextStyle(
                            fontSize: 46,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star, size: 16, color: Color(0xFFF4B400)),
                            const SizedBox(width: 4),
                            Text(
                              '$_rating (125 reviews)',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: (_subjects.isNotEmpty ? _subjects : _subject.split(','))
                              .take(4)
                              .map(
                                (item) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD9EDF3),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Text(
                                    item.trim(),
                                    style: const TextStyle(
                                      color: Color(0xFF2E6687),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
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
                                builder: (_) => TutorMessagePage(
                                  tutorId: widget.tutorId,
                                  tutorName: _name,
                                  tutorImage: _profileImage,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.chat_bubble_outline),
                          label: const Text('Message'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _togglingSaved ? null : _toggleSavedTutor,
                          icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
                          label: Text(isSaved ? 'Saved' : 'Save'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(44),
                            backgroundColor:
                                isSaved ? const Color(0xFFF4C430) : Colors.white,
                            foregroundColor: isSaved ? Colors.black : Colors.black87,
                            elevation: 0,
                            side: const BorderSide(color: Color(0xFFD1D5DB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoTile(
                          title: 'Experience',
                          value: _experienceYears,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _InfoTile(
                          title: 'Fee',
                          value: _price,
                        ),
                      ),
                    ],
                  ),
                  if (_extraFields.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x12000000),
                            blurRadius: 14,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Details',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          ..._extraFields.entries.map(
                            (entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text('${entry.key}: ${entry.value}'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  if (_availabilitySlots.isNotEmpty)
                    Builder(
                      builder: (_) {
                        final availabilityBlocks = _buildAvailabilityBlocks();
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x12000000),
                                blurRadius: 14,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Availability',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 170,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: availabilityBlocks.length,
                                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                                  itemBuilder: (context, index) {
                                    final block = availabilityBlocks[index];
                                    return Container(
                                      width: 136,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE6F4F8),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            block.dayLabel,
                                            textAlign: TextAlign.center,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Color(0xFF2A6289),
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Expanded(
                                            child: SingleChildScrollView(
                                              child: Column(
                                                children: block.times.map(
                                                  (time) => Padding(
                                                    padding: const EdgeInsets.only(bottom: 6),
                                                    child: Container(
                                                      width: double.infinity,
                                                      padding: const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 5,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFB7DAF4),
                                                        borderRadius:
                                                            BorderRadius.circular(10),
                                                      ),
                                                      child: Text(
                                                        time,
                                                        textAlign: TextAlign.center,
                                                        style: const TextStyle(
                                                          color: Color(0xFF1B4E76),
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ).toList(),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    
                  if (_availabilitySlots.isNotEmpty) const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 14,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'About Me',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(_about),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 14,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reviews',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),
                        if (_reviews.isEmpty)
                          const Text('No reviews yet')
                        else
                          ..._reviews.take(3).map((r) => _ReviewTile(review: r)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 14,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Give Review',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: List.generate(
                            5,
                            (index) {
                              final star = index + 1;
                              return IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: Icon(
                                  star <= _selectedRating ? Icons.star : Icons.star_border,
                                  color: const Color(0xFFF4B400),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _selectedRating = star;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _reviewController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Write your review here...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: _submittingReview ? null : _submitReview,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF76A96B),
                              foregroundColor: Colors.white,
                            ),
                            child: _submittingReview
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Submit Review'),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookTutorPage(
                              tutorId: widget.tutorId,
                              tutorName: _name,
                              priceLabel: _price,
                              tutorProfileImage: _profileImage,
                              availabilitySlots: _availabilitySlots,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF4FB3A5),
                              Color(0xFFA2CF7B),
                            ],
                          ),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Book Tutor',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final _TutorReview review;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey.shade300,
            child: const Icon(Icons.person, size: 16, color: Colors.black54),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        review.reviewerName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.star, size: 12, color: Color(0xFFF4B400)),
                    const SizedBox(width: 2),
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  review.comment,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorReview {
  const _TutorReview({
    required this.reviewerName,
    required this.comment,
    required this.rating,
  });

  final String reviewerName;
  final String comment;
  final double rating;
}

class _AvailabilityBlock {
  const _AvailabilityBlock({
    required this.dayLabel,
    required this.times,
  });

  final String dayLabel;
  final List<String> times;
}

class _EndpointAttempt {
  const _EndpointAttempt({required this.path, this.query});

  final String path;
  final Map<String, dynamic>? query;
}
