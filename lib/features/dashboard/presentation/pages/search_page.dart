import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/api/api_client.dart';
import 'package:tutorix/core/api/api_endpoints.dart';
import 'package:tutorix/features/dashboard/presentation/pages/tutor_profile_page.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<_TutorListItem> _allTutors = [];
  List<_TutorListItem> _visibleTutors = [];
  bool _isLoading = true;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applySearch);
    _fetchTutors();
  }

  @override
  void dispose() {
    _searchController.removeListener(_applySearch);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchTutors() async {
    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final apiClient = ref.read(apiClientProvider);

    try {
      final response = await _requestTutors(apiClient);
      final items = _extractTutorMaps(response.data)
          .map(_TutorListItem.fromJson)
          .toList();

      if (!mounted) return;

      setState(() {
        _allTutors = items;
        _visibleTutors = _filterByQuery(items, _searchController.text.trim());
        _isLoading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorText = e.response?.data is Map<String, dynamic>
            ? e.response?.data['message']?.toString()
            : e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorText = 'Failed to load tutors';
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

    DioException? lastError;

    for (final path in candidatePaths) {
      try {
        return await apiClient.get(
          path,
          queryParameters: const {'role': 'tutor'},
        );
      } on DioException catch (e) {
        if (e.response?.statusCode == 404 || e.response?.statusCode == 400) {
          try {
            return await apiClient.get(path);
          } on DioException catch (e2) {
            if (e2.response?.statusCode == 404 || e2.response?.statusCode == 400) {
              lastError = e2;
              continue;
            }
            rethrow;
          }
        }
        rethrow;
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
        .map(_safeMap)
        .where((user) {
          final role = (user['role'] ?? '').toString().toLowerCase();
          return role.isEmpty || role == 'tutor';
        })
        .toList();
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


  String _normalizeImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http://localhost:') && Platform.isAndroid) {
      return url.replaceFirst('http://localhost:', 'http://10.0.2.2:');
    }
    if (url.startsWith('http')) return url;
    return '${ApiEndpoints.mediaServerUrl}$url';
  }

  void _applySearch() {
    final filtered = _filterByQuery(_allTutors, _searchController.text.trim());
    setState(() {
      _visibleTutors = filtered;
    });
  }


  List<_TutorListItem> _filterByQuery(List<_TutorListItem> list, String query) {
    if (query.isEmpty) return list;
    final lower = query.toLowerCase();
    return list
        .where(
          (item) =>
              item.name.toLowerCase().contains(lower) ||
              item.subject.toLowerCase().contains(lower),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
        leading: const BackButton(),
        centerTitle: true,
        title: const Text(
          'Find Your Tutor',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              height: 38,
              decoration: BoxDecoration(
                border: Border.all(color: isDark ? Colors.white24 : Colors.black26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white60 : Colors.grey.shade500,
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, size: 20, color: isDark ? Colors.white70 : null),
                  suffixIcon: Icon(Icons.tune, size: 20, color: isDark ? Colors.white70 : null),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorText != null
                      ? _SearchErrorState(
                          message: _errorText!,
                          onRetry: _fetchTutors,
                        )
                      : _visibleTutors.isEmpty
                          ? const Center(child: Text('No tutors found'))
                          : ListView.separated(
                              itemCount: _visibleTutors.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final tutor = _visibleTutors[index];
                                return _TutorSearchCard(
                                  name: tutor.name,
                                  subject: tutor.subject,
                                  language: tutor.language,
                                  rating: tutor.rating,
                                  profileImage: _normalizeImageUrl(tutor.profileImage),
                                  price: tutor.price,
                                  onViewProfile: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TutorProfilePage(
                                          tutorId: tutor.id,
                                          initialName: tutor.name,
                                          initialSubject: tutor.subject,
                                          initialRating: tutor.rating,
                                          initialProfileImage:
                                              _normalizeImageUrl(tutor.profileImage),
                                          initialPrice: tutor.price,
                                          initialAbout: tutor.about,
                                          initialExperienceYears: tutor.experienceYears,
                                          initialSubjects: tutor.subjectList,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TutorSearchCard extends StatelessWidget {
  const _TutorSearchCard({
    required this.name,
    required this.subject,
    required this.language,
    required this.rating,
    required this.profileImage,
    required this.price,
    required this.onViewProfile,
  });

  final String name;
  final String subject;
  final String language;
  final String rating;
  final String profileImage;
  final String price;
  final VoidCallback onViewProfile;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            child: hasImage ? null : const Icon(Icons.person, color: Colors.grey),
            onBackgroundImageError: hasImage ? (_, __) {} : null,
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
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(Icons.star, color: Color(0xFFF4B400), size: 16),
                    const SizedBox(width: 3),
                    Text(
                      rating,
                      style: const TextStyle(fontSize: 12, color: Color(0xFFB7A044)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  language,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Text(
                      price,
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
                        onPressed: onViewProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA6F3E9),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'View Profile',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
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
  }
}

class _SearchErrorState extends StatelessWidget {
  const _SearchErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent),
          ),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _TutorListItem {
  const _TutorListItem({
    required this.id,
    required this.name,
    required this.subject,
    required this.language,
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
  final String language;
  final String rating;
  final String profileImage;
  final String price;
  final String about;
  final String experienceYears;
  final List<String> subjectList;

  factory _TutorListItem.fromJson(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id'] ?? json['userId'] ?? '').toString();
    final fullName = (json['fullName'] ?? json['name'] ?? 'Tutor').toString();

    final subjects = json['subjects'];
    final subjectSingle = json['subject'];
    final languages = json['languages'];
    final languageSingle = json['language'];
    final tags = json['tags'];

    String subjectText = 'Tutor';
    if (subjects is List && subjects.isNotEmpty) {
      subjectText = subjects.map((e) => e.toString()).join(', ');
    } else if (subjectSingle != null && subjectSingle.toString().trim().isNotEmpty) {
      subjectText = subjectSingle.toString().trim();
    } else if (tags is List && tags.isNotEmpty) {
      subjectText = tags.map((e) => e.toString()).join(', ');
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

    final image = (json['profileImage'] ?? json['avatar'] ?? '').toString();
    final about = (json['bio'] ?? json['about'] ?? '').toString();

    final experienceRaw =
        json['experienceYears'] ?? json['experience'] ?? json['yearsOfExperience'];
    final expNum = experienceRaw is num
        ? experienceRaw.toInt()
        : int.tryParse(experienceRaw?.toString() ?? '') ?? 5;

    final subjectList = <String>[];
    if (subjects is List) {
      subjectList.addAll(subjects.map((e) => e.toString()));
    } else if (subjectSingle != null && subjectSingle.toString().trim().isNotEmpty) {
      subjectList.add(subjectSingle.toString().trim());
    } else if (tags is List) {
      subjectList.addAll(tags.map((e) => e.toString()));
    } else if (languages is List) {
      subjectList.addAll(languages.map((e) => e.toString()));
    }

    String languageText = 'Language: N/A';
    if (languages is List && languages.isNotEmpty) {
      languageText = 'Language: ${languages.map((e) => e.toString()).join(', ')}';
    } else if (languageSingle != null && languageSingle.toString().trim().isNotEmpty) {
      languageText = 'Language: ${languageSingle.toString().trim()}';
    }

    return _TutorListItem(
      id: id,
      name: fullName,
      subject: subjectText,
      language: languageText,
      rating: ratingNum.toStringAsFixed(1),
      profileImage: image,
      price: 'Rs. ${priceNum.toStringAsFixed(0)}/hr',
      about: about,
      experienceYears: '$expNum Years',
      subjectList: subjectList,
    );
  }
}
