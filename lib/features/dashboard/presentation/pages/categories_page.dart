import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/api/api_client.dart';
import 'package:tutorix/core/api/api_endpoints.dart';
import 'package:tutorix/features/dashboard/presentation/pages/category_tutors_page.dart';

class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage> {
  bool _isLoading = true;
  String? _error;
  List<_CategoryItem> _categories = const [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final apiClient = ref.read(apiClientProvider);

    try {
      final list = await _requestCategories(apiClient)
        .timeout(const Duration(seconds: 15));

      if (!mounted) return;
      setState(() {
        _categories = list;
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
        _error = backendMessage ?? e.message ?? 'Failed to load categories';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to load categories';
      });
    }
  }

  Future<List<_CategoryItem>> _requestCategories(ApiClient apiClient) async {
    try {
      final response = await apiClient.get(ApiEndpoints.categories);
      final list = _extractList(response.data)
          .map(_CategoryItem.fromJson)
          .where((item) => item.name.isNotEmpty)
          .toList();

      if (list.isNotEmpty) return list;
    } on DioException catch (e) {
      if (e.response?.statusCode != 404 && e.response?.statusCode != 400) {
        rethrow;
      }
    }

    return _requestCategoriesFromTutors(apiClient);
  }

  Future<List<_CategoryItem>> _requestCategoriesFromTutors(ApiClient apiClient) async {
    final candidatePaths = <String>[
      '/tutors',
      '/users/tutors',
      '/auth/tutors',
      '/teacher/tutors',
      ApiEndpoints.users,
    ];

    DioException? lastError;
    dynamic rawData;

    for (final path in candidatePaths) {
      try {
        final response = await apiClient.get(
          path,
          queryParameters: const {'role': 'tutor'},
        );
        rawData = response.data;
        break;
      } on DioException catch (e) {
        lastError = e;
        continue;
      }
    }

    if (rawData == null) {
      throw lastError ??
          DioException(
            requestOptions: RequestOptions(path: candidatePaths.first),
            message: 'No tutor endpoint found for categories fallback',
          );
    }

    final tutors = _extractList(rawData);
    final seen = <String>{};
    final categories = <_CategoryItem>[];

    void addCategory(String value) {
      final normalized = value.trim();
      if (normalized.isEmpty) return;
      final key = normalized.toLowerCase();
      if (seen.contains(key)) return;
      seen.add(key);
      categories.add(
        _CategoryItem(
          name: normalized,
          description: 'Tutors available in $normalized',
        ),
      );
    }

    for (final tutor in tutors) {
      final extractedSubjects = _extractSubjectNames(tutor);
      for (final subject in extractedSubjects) {
        addCategory(subject);
      }
    }

    return categories;
  }

  List<String> _extractSubjectNames(Map<String, dynamic> tutor) {
    final values = <String>[];

    final subjects = tutor['subjects'];
    if (subjects is List) {
      for (final item in subjects) {
        if (item is Map) {
          final name = item['name'] ?? item['title'] ?? item['subject'];
          if (name != null) values.add(name.toString());
        } else if (item != null) {
          values.add(item.toString());
        }
      }
    }

    final subject = tutor['subject'];
    if (subject is String && subject.trim().isNotEmpty) {
      values.addAll(
        subject
            .split(RegExp(r'[,/&]'))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty),
      );
    } else if (subject is List) {
      for (final item in subject) {
        if (item != null) values.add(item.toString());
      }
    }

    return values;
  }

  List<Map<String, dynamic>> _extractList(dynamic raw) {
    final source = raw is Map<String, dynamic> ? raw['data'] : raw;
    if (source is! List) return [];

    return source.whereType<Map>().map((item) {
      final map = <String, dynamic>{};
      item.forEach((key, value) {
        if (key != null) map[key.toString()] = value;
      });
      return map;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Categories'),
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
                          onPressed: _fetchCategories,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _categories.isEmpty
                  ? const Center(child: Text('No categories available'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _categories.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.6,
                      ),
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CategoryTutorsPage(
                                  categoryName: category.name,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.black12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  category.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                if (category.description.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    category.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

class _CategoryItem {
  const _CategoryItem({
    required this.name,
    required this.description,
  });

  final String name;
  final String description;

  factory _CategoryItem.fromJson(Map<String, dynamic> json) {
    return _CategoryItem(
      name: (json['name'] ?? json['title'] ?? '').toString().trim(),
      description: (json['description'] ?? json['desc'] ?? '').toString().trim(),
    );
  }
}
