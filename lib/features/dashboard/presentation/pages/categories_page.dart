// import 'dart:async';

// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:tutorix/core/api/api_client.dart';
// import 'package:tutorix/core/api/api_endpoints.dart';
// import 'package:tutorix/features/dashboard/presentation/pages/category_tutors_page.dart';

// class CategoriesPage extends ConsumerStatefulWidget {
//   const CategoriesPage({super.key});

//   @override
//   ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
// }

// class _CategoriesPageState extends ConsumerState<CategoriesPage> {
//   bool _isLoading = true;
//   String? _error;
//   List<_CategoryItem> _categories = const [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchCategories();
//   }

//   Future<void> _fetchCategories() async {
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });

//     final apiClient = ref.read(apiClientProvider);

//     try {
//       final list = await _requestCategories(apiClient).timeout(const Duration(seconds: 15));
//       final subjectCounts = await _requestTutorSubjectCounts(apiClient);

//       final merged = list
//           .map((item) {
//             final mapCount = subjectCounts[item.name.toLowerCase()];
//             return item.copyWith(
//               tutorCount: mapCount ?? item.tutorCount,
//             );
//           })
//           .toList();

//       if (!mounted) return;
//       setState(() {
//         _categories = merged;
//         _isLoading = false;
//       });
//     } on TimeoutException {
//       if (!mounted) return;
//       setState(() {
//         _isLoading = false;
//         _error = 'Request timed out. Please try again.';
//       });
//     } on DioException catch (e) {
//       if (!mounted) return;
//       final responseData = e.response?.data;
//       final backendMessage = responseData is Map
//           ? responseData['message']?.toString()
//           : null;
//       setState(() {
//         _isLoading = false;
//         _error = backendMessage ?? e.message ?? 'Failed to load categories';
//       });
//     } catch (_) {
//       if (!mounted) return;
//       setState(() {
//         _isLoading = false;
//         _error = 'Failed to load categories';
//       });
//     }
//   }

//   Future<List<_CategoryItem>> _requestCategories(ApiClient apiClient) async {
//     try {
//       final response = await apiClient.get(ApiEndpoints.categories);
//       final list = _extractList(response.data)
//           .map(_CategoryItem.fromJson)
//           .where((item) => item.name.isNotEmpty)
//           .toList();

//       if (list.isNotEmpty) return list;
//     } on DioException catch (e) {
//       if (e.response?.statusCode != 404 && e.response?.statusCode != 400) {
//         rethrow;
//       }
//     }

//     return _requestCategoriesFromTutors(apiClient);
//   }

//   Future<List<_CategoryItem>> _requestCategoriesFromTutors(ApiClient apiClient) async {
//     final tutors = await _requestTutors(apiClient);
//     final seen = <String>{};
//     final categories = <_CategoryItem>[];

//     void addCategory(String value) {
//       final normalized = value.trim();
//       if (normalized.isEmpty) return;
//       final key = normalized.toLowerCase();
//       if (seen.contains(key)) return;
//       seen.add(key);
//       categories.add(
//         _CategoryItem(
//           name: normalized,
//           description: 'Tutors available in $normalized',
//           tutorCount: null,
//         ),
//       );
//     }

//     for (final tutor in tutors) {
//       final extractedSubjects = _extractSubjectNames(tutor);
//       for (final subject in extractedSubjects) {
//         addCategory(subject);
//       }
//     }

//     return categories;
//   }

//   Future<List<Map<String, dynamic>>> _requestTutors(ApiClient apiClient) async {
//     final candidatePaths = <String>[
//       '/tutors',
//       '/users/tutors',
//       '/auth/tutors',
//       '/teacher/tutors',
//       ApiEndpoints.users,
//     ];

//     DioException? lastError;

//     for (final path in candidatePaths) {
//       try {
//         final response = await apiClient.get(
//           path,
//           queryParameters: const {'role': 'tutor'},
//         );
//         return _extractList(response.data)
//             .where((user) {
//               final role = (user['role'] ?? '').toString().toLowerCase();
//               return role.isEmpty || role == 'tutor';
//             })
//             .toList();
//       } on DioException catch (e) {
//         lastError = e;
//       }
//     }

//     throw lastError ??
//         DioException(
//           requestOptions: RequestOptions(path: candidatePaths.first),
//           message: 'No tutor endpoint found for categories fallback',
//         );
//   }

//   Future<Map<String, int>> _requestTutorSubjectCounts(ApiClient apiClient) async {
//     try {
//       final tutors = await _requestTutors(apiClient);
//       final counts = <String, int>{};

//       for (final tutor in tutors) {
//         final subjects = _extractSubjectNames(tutor)
//             .map((subject) => subject.trim())
//             .where((subject) => subject.isNotEmpty)
//             .toSet();

//         for (final subject in subjects) {
//           final key = subject.toLowerCase();
//           counts[key] = (counts[key] ?? 0) + 1;
//         }
//       }

//       return counts;
//     } catch (_) {
//       return const {};
//     }
//   }

//   IconData _iconForCategory(String categoryName) {
//     final lower = categoryName.toLowerCase();
//     if (lower.contains('math')) return Icons.calculate_rounded;
//     if (lower.contains('physic')) return Icons.science_rounded;
//     if (lower.contains('chem')) return Icons.biotech_rounded;
//     if (lower.contains('bio')) return Icons.bubble_chart_rounded;
//     if (lower.contains('computer') || lower.contains('data')) return Icons.computer_rounded;
//     if (lower.contains('english') || lower.contains('language')) return Icons.menu_book_rounded;
//     if (lower.contains('history')) return Icons.history_edu_rounded;
//     if (lower.contains('geography')) return Icons.public_rounded;
//     return Icons.school_rounded;
//   }

//   _CategoryStyle _styleForIndex(int index) {
//     const styles = <_CategoryStyle>[
//       _CategoryStyle(
//         start: Color(0xFF6EC6FF),
//         end: Color(0xFF4A90E2),
//         titleColor: Color(0xFF0D2E6A),
//       ),
//       _CategoryStyle(
//         start: Color(0xFFC89BFF),
//         end: Color(0xFF8E67D7),
//         titleColor: Colors.white,
//       ),
//       _CategoryStyle(
//         start: Color(0xFFFFC0D7),
//         end: Color(0xFFF7A0BF),
//         titleColor: Color(0xFFB22A2A),
//       ),
//       _CategoryStyle(
//         start: Color(0xFFCDEB7E),
//         end: Color(0xFFA9D65A),
//         titleColor: Color(0xFF285B2B),
//       ),
//       _CategoryStyle(
//         start: Color(0xFF93DAFF),
//         end: Color(0xFF6CC2EA),
//         titleColor: Color(0xFF204A73),
//       ),
//       _CategoryStyle(
//         start: Color(0xFF9EB2FF),
//         end: Color(0xFF7D8DFA),
//         titleColor: Color(0xFF2A2B7A),
//       ),
//       _CategoryStyle(
//         start: Color(0xFFFFCD8B),
//         end: Color(0xFFF5AA5C),
//         titleColor: Color(0xFF9A4A00),
//       ),
//       _CategoryStyle(
//         start: Color(0xFFBAE8AA),
//         end: Color(0xFF96D38C),
//         titleColor: Color(0xFF1F5B2F),
//       ),
//     ];

//     return styles[index % styles.length];
//   }

//   List<String> _extractSubjectNames(Map<String, dynamic> tutor) {
//     final values = <String>[];

//     final subjects = tutor['subjects'];
//     if (subjects is List) {
//       for (final item in subjects) {
//         if (item is Map) {
//           final name = item['name'] ?? item['title'] ?? item['subject'];
//           if (name != null) values.add(name.toString());
//         } else if (item != null) {
//           values.add(item.toString());
//         }
//       }
//     }

//     final subject = tutor['subject'];
//     if (subject is String && subject.trim().isNotEmpty) {
//       values.addAll(
//         subject
//             .split(RegExp(r'[,/&]'))
//             .map((e) => e.trim())
//             .where((e) => e.isNotEmpty),
//       );
//     } else if (subject is List) {
//       for (final item in subject) {
//         if (item != null) values.add(item.toString());
//       }
//     }

//     return values;
//   }

//   List<Map<String, dynamic>> _extractList(dynamic raw) {
//     final source = raw is Map<String, dynamic> ? raw['data'] : raw;
//     if (source is! List) return [];

//     return source.whereType<Map>().map((item) {
//       final map = <String, dynamic>{};
//       item.forEach((key, value) {
//         if (key != null) map[key.toString()] = value;
//       });
//       return map;
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final screenWidth = MediaQuery.sizeOf(context).width;
//     final compact = screenWidth < 380;
//     final gridRatio = compact ? 1.62 : 1.85;

//     return Scaffold(
//       backgroundColor: isDark ? Colors.black : Colors.white,
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _error != null
//               ? Center(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           _error!,
//                           textAlign: TextAlign.center,
//                           style: const TextStyle(color: Colors.redAccent),
//                         ),
//                         const SizedBox(height: 10),
//                         OutlinedButton(
//                           onPressed: _fetchCategories,
//                           child: const Text('Retry'),
//                         ),
//                       ],
//                     ),
//                   ),
//                 )
//               : _categories.isEmpty
//                   ? const Center(child: Text('No categories available'))
//                   : Container(
//                       decoration: BoxDecoration(
//                         color: isDark ? Colors.black : const Color(0xFFF1EEF8),
//                       ),
//                       child: SafeArea(
//                         child: Column(
//                           children: [
//                             const SizedBox(height: 8),
//                             Text(
//                               'Categories',
//                               style: TextStyle(
//                                 fontSize: 42,
//                                 fontWeight: FontWeight.w800,
//                                 color: isDark ? Colors.white : const Color(0xFF2B2B33),
//                               ),
//                             ),
//                             const SizedBox(height: 12),
//                             Expanded(
//                               child: GridView.builder(
//                                 padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
//                                 itemCount:
//                                     _categories.length + (_categories.length.isOdd ? 1 : 0),
//                                 gridDelegate:
//                                     SliverGridDelegateWithFixedCrossAxisCount(
//                                   crossAxisCount: 2,
//                                   mainAxisSpacing: 12,
//                                   crossAxisSpacing: 12,
//                                   childAspectRatio: gridRatio,
//                                 ),
//                                 itemBuilder: (context, index) {
//                                   final isPlaceholder =
//                                       _categories.length.isOdd && index == _categories.length;

//                                   if (isPlaceholder) {
//                                     return Container(
//                                       decoration: BoxDecoration(
//                                         color: isDark
//                                             ? const Color(0xFF111111)
//                                             : const Color(0xFFEDEAF2),
//                                         borderRadius: BorderRadius.circular(22),
//                                       ),
//                                     );
//                                   }

//                                   final category = _categories[index];
//                                   final style = _styleForIndex(index);
//                                   final subtitle = category.tutorCount == null
//                                       ? 'Tutors available in ${category.name}'
//                                       : '${category.tutorCount} tutors available in ${category.name}';

//                                   return InkWell(
//                                     borderRadius: BorderRadius.circular(22),
//                                     onTap: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (_) => CategoryTutorsPage(
//                                             categoryName: category.name,
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                     child: Container(
//                                       padding: EdgeInsets.symmetric(
//                                         horizontal: compact ? 10 : 14,
//                                         vertical: compact ? 10 : 12,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         borderRadius: BorderRadius.circular(22),
//                                         gradient: LinearGradient(
//                                           begin: Alignment.topLeft,
//                                           end: Alignment.bottomRight,
//                                           colors: [style.start, style.end],
//                                         ),
//                                         boxShadow: const [
//                                           BoxShadow(
//                                             color: Color(0x22000000),
//                                             blurRadius: 10,
//                                             offset: Offset(0, 4),
//                                           ),
//                                         ],
//                                       ),
//                                       child: Row(
//                                         children: [
//                                           Container(
//                                             width: compact ? 46 : 54,
//                                             height: compact ? 46 : 54,
//                                             decoration: BoxDecoration(
//                                               color: Colors.white.withOpacity(0.23),
//                                               shape: BoxShape.circle,
//                                             ),
//                                             child: Icon(
//                                               _iconForCategory(category.name),
//                                               size: compact ? 24 : 30,
//                                               color: style.titleColor,
//                                             ),
//                                           ),
//                                           SizedBox(width: compact ? 8 : 10),
//                                           Expanded(
//                                             child: Column(
//                                               mainAxisAlignment: MainAxisAlignment.center,
//                                               crossAxisAlignment: CrossAxisAlignment.start,
//                                               children: [
//                                                 Text(
//                                                   category.name,
//                                                   maxLines: compact ? 1 : 2,
//                                                   overflow: TextOverflow.ellipsis,
//                                                   style: TextStyle(
//                                                     fontSize: compact ? 15 : 18,
//                                                     height: 1,
//                                                     fontWeight: FontWeight.w800,
//                                                     color: style.titleColor,
//                                                   ),
//                                                 ),
//                                                 SizedBox(height: compact ? 4 : 6),
//                                                 Text(
//                                                   subtitle,
//                                                   maxLines: compact ? 1 : 2,
//                                                   overflow: TextOverflow.ellipsis,
//                                                   style: TextStyle(
//                                                     fontSize: compact ? 11 : 12.5,
//                                                     color: style.titleColor.withOpacity(0.9),
//                                                     fontWeight: FontWeight.w500,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//     );
//   }
// }

// class _CategoryItem {
//   const _CategoryItem({
//     required this.name,
//     required this.description,
//     this.tutorCount,
//   });

//   final String name;
//   final String description;
//   final int? tutorCount;

//   _CategoryItem copyWith({
//     String? name,
//     String? description,
//     int? tutorCount,
//   }) {
//     return _CategoryItem(
//       name: name ?? this.name,
//       description: description ?? this.description,
//       tutorCount: tutorCount,
//     );
//   }

//   factory _CategoryItem.fromJson(Map<String, dynamic> json) {
//     int? parseCount(dynamic raw) {
//       if (raw is num) return raw.toInt();
//       return int.tryParse(raw?.toString() ?? '');
//     }

//     return _CategoryItem(
//       name: (json['name'] ?? json['title'] ?? '').toString().trim(),
//       description: (json['description'] ?? json['desc'] ?? '').toString().trim(),
//       tutorCount: parseCount(
//         json['tutorCount'] ?? json['tutorsCount'] ?? json['count'] ?? json['totalTutors'],
//       ),
//     );
//   }
// }

// class _CategoryStyle {
//   const _CategoryStyle({
//     required this.start,
//     required this.end,
//     required this.titleColor,
//   });

//   final Color start;
//   final Color end;
//   final Color titleColor;
// }



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

      final subjectCounts = await _requestTutorSubjectCounts(apiClient);

      final merged = list.map((item) {
        final mapCount = subjectCounts[item.name.toLowerCase()];
        return item.copyWith(
          tutorCount: mapCount ?? item.tutorCount,
        );
      }).toList();

      if (!mounted) return;

      setState(() {
        _categories = merged;
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

      final backendMessage =
          responseData is Map ? responseData['message']?.toString() : null;

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

  Future<List<_CategoryItem>> _requestCategoriesFromTutors(
      ApiClient apiClient) async {
    final tutors = await _requestTutors(apiClient);

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
          tutorCount: null,
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

  Future<List<Map<String, dynamic>>> _requestTutors(ApiClient apiClient) async {
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
        final response = await apiClient.get(
          path,
          queryParameters: const {'role': 'tutor'},
        );

        return _extractList(response.data)
            .where((user) {
              final role = (user['role'] ?? '').toString().toLowerCase();
              return role.isEmpty || role == 'tutor';
            })
            .toList();
      } on DioException catch (e) {
        lastError = e;
      }
    }

    throw lastError ??
        DioException(
          requestOptions: RequestOptions(path: candidatePaths.first),
          message: 'No tutor endpoint found for categories fallback',
        );
  }

  Future<Map<String, int>> _requestTutorSubjectCounts(
      ApiClient apiClient) async {
    try {
      final tutors = await _requestTutors(apiClient);

      final counts = <String, int>{};

      for (final tutor in tutors) {
        final subjects = _extractSubjectNames(tutor)
            .map((subject) => subject.trim())
            .where((subject) => subject.isNotEmpty)
            .toSet();

        for (final subject in subjects) {
          final key = subject.toLowerCase();
          counts[key] = (counts[key] ?? 0) + 1;
        }
      }

      return counts;
    } catch (_) {
      return const {};
    }
  }

  IconData _iconForCategory(String categoryName) {
    final lower = categoryName.toLowerCase();

    if (lower.contains('math')) return Icons.calculate_rounded;
    if (lower.contains('physic')) return Icons.science_rounded;
    if (lower.contains('chem')) return Icons.biotech_rounded;
    if (lower.contains('bio')) return Icons.bubble_chart_rounded;
    if (lower.contains('computer') || lower.contains('data'))
      return Icons.computer_rounded;
    if (lower.contains('english') || lower.contains('language'))
      return Icons.menu_book_rounded;
    if (lower.contains('history')) return Icons.history_edu_rounded;
    if (lower.contains('geography')) return Icons.public_rounded;

    return Icons.school_rounded;
  }

  _CategoryStyle _styleForIndex(int index) {
    const styles = <_CategoryStyle>[
      _CategoryStyle(
        start: Color(0xFF6EC6FF),
        end: Color(0xFF4A90E2),
        titleColor: Color(0xFF0D2E6A),
      ),
      _CategoryStyle(
        start: Color(0xFFC89BFF),
        end: Color(0xFF8E67D7),
        titleColor: Colors.white,
      ),
      _CategoryStyle(
        start: Color(0xFFFFC0D7),
        end: Color(0xFFF7A0BF),
        titleColor: Color(0xFFB22A2A),
      ),
      _CategoryStyle(
        start: Color(0xFFCDEB7E),
        end: Color(0xFFA9D65A),
        titleColor: Color(0xFF285B2B),
      ),
      _CategoryStyle(
        start: Color(0xFF93DAFF),
        end: Color(0xFF6CC2EA),
        titleColor: Color(0xFF204A73),
      ),
      _CategoryStyle(
        start: Color(0xFF9EB2FF),
        end: Color(0xFF7D8DFA),
        titleColor: Color(0xFF2A2B7A),
      ),
      _CategoryStyle(
        start: Color(0xFFFFCD8B),
        end: Color(0xFFF5AA5C),
        titleColor: Color(0xFF9A4A00),
      ),
      _CategoryStyle(
        start: Color(0xFFBAE8AA),
        end: Color(0xFF96D38C),
        titleColor: Color(0xFF1F5B2F),
      ),
    ];

    return styles[index % styles.length];
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screenWidth = MediaQuery.sizeOf(context).width;

    final compact = screenWidth < 380;

    final gridRatio = compact ? 1.4 : 1.55;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black : const Color(0xFFF1EEF8),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          'Categories',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF2B2B33),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 4),
                            itemCount:
                                _categories.length + (_categories.length.isOdd ? 1 : 0),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: gridRatio,
                            ),
                            itemBuilder: (context, index) {
                              final isPlaceholder =
                                  _categories.length.isOdd &&
                                      index == _categories.length;

                              if (isPlaceholder) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF111111)
                                        : const Color(0xFFEDEAF2),
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                );
                              }

                              final category = _categories[index];
                              final style = _styleForIndex(index);

                              final subtitle = category.tutorCount == null
                                  ? 'Tutors available'
                                  : '${category.tutorCount} tutors available';

                              return InkWell(
                                borderRadius: BorderRadius.circular(22),
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
                                    borderRadius: BorderRadius.circular(22),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [style.start, style.end],
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x22000000),
                                        blurRadius: 10,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.25),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          _iconForCategory(category.name),
                                          size: 26,
                                          color: style.titleColor,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                category.name,
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w800,
                                                  color: style.titleColor,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Flexible(
                                              child: Text(
                                                subtitle,
                                                maxLines: 2,
                                                overflow:
                                                    TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: style.titleColor
                                                      .withOpacity(0.9),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

class _CategoryItem {
  const _CategoryItem({
    required this.name,
    required this.description,
    this.tutorCount,
  });

  final String name;
  final String description;
  final int? tutorCount;

  _CategoryItem copyWith({
    String? name,
    String? description,
    int? tutorCount,
  }) {
    return _CategoryItem(
      name: name ?? this.name,
      description: description ?? this.description,
      tutorCount: tutorCount,
    );
  }

  factory _CategoryItem.fromJson(Map<String, dynamic> json) {
    int? parseCount(dynamic raw) {
      if (raw is num) return raw.toInt();
      return int.tryParse(raw?.toString() ?? '');
    }

    return _CategoryItem(
      name: (json['name'] ?? json['title'] ?? '').toString().trim(),
      description:
          (json['description'] ?? json['desc'] ?? '').toString().trim(),
      tutorCount: parseCount(
        json['tutorCount'] ??
            json['tutorsCount'] ??
            json['count'] ??
            json['totalTutors'],
      ),
    );
  }
}

class _CategoryStyle {
  const _CategoryStyle({
    required this.start,
    required this.end,
    required this.titleColor,
  });

  final Color start;
  final Color end;
  final Color titleColor;
}