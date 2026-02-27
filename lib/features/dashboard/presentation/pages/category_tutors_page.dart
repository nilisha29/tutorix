import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/api/api_client.dart';
import 'package:tutorix/core/api/api_endpoints.dart';
import 'package:tutorix/features/dashboard/presentation/pages/tutor_profile_page.dart';

class CategoryTutorsPage extends ConsumerStatefulWidget {
  const CategoryTutorsPage({
    super.key,
    required this.categoryName,
  });

  final String categoryName;

  @override
  ConsumerState<CategoryTutorsPage> createState() => _CategoryTutorsPageState();
}

class _CategoryTutorsPageState extends ConsumerState<CategoryTutorsPage> {
  bool _isLoading = true;
  String? _error;
  List<_TutorItem> _tutors = const [];

  @override
  void initState() {
    super.initState();
    _fetchTutorsByCategory();
  }

  Future<void> _fetchTutorsByCategory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final apiClient = ref.read(apiClientProvider);

    try {
      final response = await _requestTutors(apiClient)
          .timeout(const Duration(seconds: 15));

      final allTutors = _extractTutorMaps(response.data)
          .map(_TutorItem.fromJson)
          .toList();

      final category = widget.categoryName.toLowerCase().trim();
      final filtered = allTutors.where((tutor) {
        final subjectTokens = <String>{
          tutor.subject.toLowerCase().trim(),
          ...tutor.subjectList.map((s) => s.toLowerCase().trim()),
        };

        return subjectTokens.any(
          (value) => value == category ||
              value.contains(category) ||
              category.contains(value),
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _tutors = filtered;
        _isLoading = false;
      });
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Request timed out. Please try again.';
      });
    } on DioException catch (e) {
      if (!mounted) return;
      final responseData = e.response?.data;
      final backendMessage = responseData is Map
          ? responseData['message']?.toString()
          : null;
      setState(() {
        _isLoading = false;
        _error = backendMessage ?? e.message ?? 'Failed to load tutors';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to load tutors';
      });
    }
  }

  Future<Response<dynamic>> _requestTutors(ApiClient apiClient) async {
    final candidatePaths = <String>[
      '/tutors',
      '/users/tutors',
      '/auth/tutors',
      '/teacher/tutors',
      ApiEndpoints.users,
    ];

    final category = widget.categoryName;
    final queryCandidates = <Map<String, dynamic>>[
      {'role': 'tutor', 'category': category},
      {'role': 'tutor', 'subject': category},
      {'role': 'tutor', 'specialization': category},
      {'role': 'tutor', 'tag': category},
      {'role': 'tutor'},
      {'category': category},
      {'subject': category},
      {},
    ];

    DioException? lastError;

    for (final path in candidatePaths) {
      for (final query in queryCandidates) {
        try {
          return await apiClient.get(
            path,
            queryParameters: query.isEmpty ? null : query,
          );
        } on DioException catch (e) {
          lastError = e;
          continue;
        }
      }
    }

    throw lastError ??
        DioException(
          requestOptions: RequestOptions(path: candidatePaths.first),
          message: 'No tutor endpoint found on backend',
        );
  }

  List<Map<String, dynamic>> _extractTutorMaps(dynamic rawData) {
    final source = rawData is Map<String, dynamic> ? rawData['data'] : rawData;
    if (source is! List) return [];

    return source
        .whereType<Map>()
        .map((raw) {
          final map = <String, dynamic>{};
          raw.forEach((key, value) {
            if (key != null) map[key.toString()] = value;
          });
          return map;
        })
        .where((user) {
          final role = (user['role'] ?? '').toString().toLowerCase();
          return role.isEmpty || role == 'tutor';
        })
        .toList();
  }

  String _normalizeImageUrl(String? url) {
    if (url == null) return '';
    final value = url.trim();
    if (value.isEmpty || value.toLowerCase() == 'null') return '';
    if (value.startsWith('http://localhost:') && Platform.isAndroid) {
      return value.replaceFirst('http://localhost:', 'http://10.0.2.2:');
    }
    if (value.startsWith('http')) return value;
    if (value.startsWith('/')) return '${ApiEndpoints.mediaServerUrl}$value';
    return '${ApiEndpoints.mediaServerUrl}/$value';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text('${widget.categoryName} Tutors'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: _fetchTutorsByCategory,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _tutors.isEmpty
                  ? Center(child: Text('No ${widget.categoryName} tutors found'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _tutors.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final tutor = _tutors[index];
                        final profileImage = _normalizeImageUrl(tutor.profileImage);
                        final hasImage = profileImage.isNotEmpty;

                        return Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF111111) : Colors.white,
                            border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: Colors.grey.shade200,
                                backgroundImage: hasImage ? NetworkImage(profileImage) : null,
                                onBackgroundImageError: hasImage ? (_, __) {} : null,
                                child: hasImage
                                    ? null
                                    : const Icon(Icons.person, color: Colors.grey),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            tutor.name,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.star,
                                          color: Color(0xFFF4B400),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          tutor.rating,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFFB7A044),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      tutor.subject,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Row(
                                      children: [
                                        Text(
                                          tutor.price,
                                          style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const Spacer(),
                                        SizedBox(
                                          height: 28,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => TutorProfilePage(
                                                    tutorId: tutor.id,
                                                    initialName: tutor.name,
                                                    initialSubject: tutor.subject,
                                                    initialRating: tutor.rating,
                                                    initialProfileImage: profileImage,
                                                    initialPrice: tutor.price,
                                                    initialAbout: tutor.about,
                                                    initialExperienceYears:
                                                        tutor.experienceYears,
                                                    initialSubjects: tutor.subjectList,
                                                  ),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFFA6F3E9),
                                              foregroundColor: Colors.black,
                                              elevation: 0,
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                            ),
                                            child: const Text(
                                              'View Profile',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}

class _TutorItem {
  const _TutorItem({
    required this.id,
    required this.name,
    required this.subject,
    required this.rating,
    required this.profileImage,
    required this.price,
    required this.about,
    required this.experienceYears,
    required this.subjectList,
  });

  final String id;
  final String name;
  final String subject;
  final String rating;
  final String profileImage;
  final String price;
  final String about;
  final String experienceYears;
  final List<String> subjectList;

  static List<String> _extractSubjects(Map<String, dynamic> json) {
    final results = <String>[];

    final subjects = json['subjects'];
    if (subjects is List) {
      for (final item in subjects) {
        if (item is Map) {
          final value = item['name'] ?? item['title'] ?? item['subject'];
          if (value != null && value.toString().trim().isNotEmpty) {
            results.add(value.toString().trim());
          }
        } else if (item != null && item.toString().trim().isNotEmpty) {
          results.add(item.toString().trim());
        }
      }
    }

    final subject = json['subject'];
    if (subject is String && subject.trim().isNotEmpty) {
      results.addAll(
        subject
            .split(RegExp(r'[,/&]'))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty),
      );
    } else if (subject is List) {
      for (final item in subject) {
        if (item != null && item.toString().trim().isNotEmpty) {
          results.add(item.toString().trim());
        }
      }
    }

    return results;
  }

  factory _TutorItem.fromJson(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id'] ?? json['userId'] ?? '').toString();
    final fullName = (json['fullName'] ?? json['name'] ?? 'Tutor').toString();

    final subjectList = _extractSubjects(json);

    String subjectText = 'Tutor';
    if (subjectList.isNotEmpty) {
      subjectText = subjectList.join(', ');
    } else if (json['bio'] != null && json['bio'].toString().trim().isNotEmpty) {
      subjectText = json['bio'].toString().trim();
    }

    final ratingRaw = json['averageRating'] ?? json['rating'] ?? 4.9;
    final ratingNum = ratingRaw is num
        ? ratingRaw.toDouble()
        : double.tryParse(ratingRaw.toString()) ?? 4.9;

    final priceRaw = json['hourlyRate'] ?? json['pricePerHour'] ?? json['price'] ?? 60;
    final priceNum = priceRaw is num
        ? priceRaw.toDouble()
        : double.tryParse(priceRaw.toString()) ?? 60;

    final image = (json['profileImage'] ?? json['profilePicture'] ?? json['avatar'] ?? '')
        .toString();
    final about = (json['bio'] ?? json['about'] ?? '').toString();

    final experienceRaw =
        json['experienceYears'] ?? json['experience'] ?? json['yearsOfExperience'];
    final expNum = experienceRaw is num
        ? experienceRaw.toInt()
        : int.tryParse(experienceRaw?.toString() ?? '') ?? 5;

    return _TutorItem(
      id: id,
      name: fullName,
      subject: subjectText,
      rating: ratingNum.toStringAsFixed(1),
      profileImage: image,
      price: 'Rs. ${priceNum.toStringAsFixed(0)}/hr',
      about: about,
      experienceYears: '$expNum Years',
      subjectList: subjectList,
    );
  }
}
