import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/api/api_client.dart';
import 'package:tutorix/core/api/api_endpoints.dart';


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
  List<_TutorReview> _reviews = [];
  Map<String, String> _extraFields = {};

  final TextEditingController _reviewController = TextEditingController();
  int _selectedRating = 5;
  bool _submittingReview = false;

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
    final languages = data['languages'];
    final tags = data['tags'];

    if (subjects is List && subjects.isNotEmpty) {
      subjectList.addAll(subjects.map((e) => e.toString()));
    } else if (languages is List && languages.isNotEmpty) {
      subjectList.addAll(languages.map((e) => e.toString()));
    } else if (tags is List && tags.isNotEmpty) {
      subjectList.addAll(tags.map((e) => e.toString()));
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

    final image = (data['profileImage'] ?? data['avatar'] ?? '').toString();


    final extras = <String, String>{
      if ((data['email'] ?? '').toString().isNotEmpty)
        'Email': (data['email']).toString(),
      if ((data['phoneNumber'] ?? '').toString().isNotEmpty)
        'Phone': (data['phoneNumber']).toString(),
      if ((data['address'] ?? '').toString().isNotEmpty)
        'Address': (data['address']).toString(),
      if ((data['qualification'] ?? '').toString().isNotEmpty)
        'Qualification': (data['qualification']).toString(),
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
    _reviews = reviews;
    _extraFields = extras;
  }

  String _normalizeImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http://localhost:') && Platform.isAndroid) {
      return url.replaceFirst('http://localhost:', 'http://10.0.2.2:');
    }
    if (url.startsWith('http')) return url;
    return '${ApiEndpoints.mediaServerUrl}$url';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        foregroundColor: Colors.black,
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 42,
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
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star, size: 16, color: Color(0xFFF4B400)),
                            const SizedBox(width: 4),
                            Text('$_rating (125 reviews)'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (_subjects.isNotEmpty ? _subjects : _subject.split(','))
                        .take(4)
                        .map(
                          (item) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.black26),
                            ),
                            child: Text(item.trim()),
                          ),
                        )
                        .toList(),
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
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black12),
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
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black12),
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
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black12),
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
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black12),
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
                                  star <= _selectedRating
                                      ? Icons.star
                                      : Icons.star_border,
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
                  SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF76A96B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: const Text(
                        'Book Tutor',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.grey.shade300,
                child: const Icon(Icons.person, size: 14, color: Colors.black54),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  review.reviewerName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const Icon(Icons.star, size: 14, color: Color(0xFFF4B400)),
              const SizedBox(width: 3),
              Text(review.rating.toStringAsFixed(1)),
            ],
          ),
          const SizedBox(height: 6),
          Text(review.comment),
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
