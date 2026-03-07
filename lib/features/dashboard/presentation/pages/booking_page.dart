// import 'package:flutter/material.dart';

// class BookingPage extends StatelessWidget {
//   const BookingPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Booking'),
//         backgroundColor: Colors.green,
//       ),
//       body: const Center(
//         child: Text(
//           'Welcome to the Booking Page',
//           style: TextStyle(fontSize: 20),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:sensors_plus/sensors_plus.dart';
import 'package:tutorix/core/api/api_client.dart';
import 'package:tutorix/core/api/api_endpoints.dart';
import 'package:tutorix/core/constants/hive_table_constant.dart';
import 'package:tutorix/core/services/connectivity/network_info.dart';
import 'package:tutorix/core/services/hive/hive_service.dart';
import 'package:tutorix/features/bookings/presentation/state/booking_store.dart';

class BookingPage extends ConsumerStatefulWidget {
  const BookingPage({super.key});

  @override
  ConsumerState<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends ConsumerState<BookingPage> {
  final TextEditingController _searchController = TextEditingController();
  StreamSubscription<AccelerometerEvent>? _shakeSubscription;
  DateTime? _lastShakeAt;

  static const double _shakeThreshold = 17.0;
  static const Duration _shakeCooldown = Duration(milliseconds: 1400);

  String _query = '';
  bool _loading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _listenForShakeReload();
    _fetchBookings();
  }

  void _listenForShakeReload() {
    _shakeSubscription = accelerometerEventStream().listen((event) {
      if (!mounted || _loading) return;

      final now = DateTime.now();
      final last = _lastShakeAt;
      if (last != null && now.difference(last) < _shakeCooldown) return;

      final magnitude = math.sqrt(
        (event.x * event.x) + (event.y * event.y) + (event.z * event.z),
      );

      if (magnitude >= _shakeThreshold) {
        _lastShakeAt = now;
        _fetchBookings();
      }
    });
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _loading = true;
      _errorText = null;
    });

    final hasInternet = await ref.read(networkInfoProvider).isConnected;
    final hiveService = ref.read(hiveServiceProvider);
    if (!hasInternet) {
      final cachedRaw = hiveService.getCachedData(HiveTableConstant.bookingsCacheKey);
      final cachedRows = _extractList(cachedRaw);
      final cachedBookings = cachedRows
          .map(_toBookingRecord)
          .whereType<BookingRecord>()
          .toList();
      final mergedCached = _mergeWithLocalBookings(cachedBookings);

      if (mergedCached.isNotEmpty) {
        BookingStore.setBookings(mergedCached);
        if (!mounted) return;
        setState(() {
          _loading = false;
          _errorText = null;
        });
        return;
      }

      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorText = 'Offline mode: connect internet to refresh bookings.';
      });
      return;
    }

    final apiClient = ref.read(apiClientProvider);

    final endpointCandidates = <String>[
      '/bookings/my-student',
      '/bookings/my',
      '/bookings',
    ];

    try {
      for (final endpoint in endpointCandidates) {
        try {
          final response = await apiClient.get(endpoint);
          final rows = _extractList(response.data);

            await hiveService.setCachedData(HiveTableConstant.bookingsCacheKey, rows);

          final parsed = rows
              .map(_toBookingRecord)
              .whereType<BookingRecord>()
              .toList();
            final merged = _mergeWithLocalBookings(parsed);
            BookingStore.setBookings(merged);
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
      setState(() {
        _errorText = 'Failed to load bookings from backend';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<dynamic> _extractList(dynamic raw) {
    if (raw is Map && raw['data'] is List) return raw['data'] as List<dynamic>;
    if (raw is List) return raw;
    return const [];
  }

  List<BookingRecord> _mergeWithLocalBookings(List<BookingRecord> remote) {
    final local = BookingStore.bookings.value;
    final localOnly = local.where((item) => !_containsBooking(remote, item)).toList();
    final merged = <BookingRecord>[...localOnly, ...remote];
    merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return merged;
  }

  bool _containsBooking(List<BookingRecord> haystack, BookingRecord needle) {
    return haystack.any((row) {
      final sameTutor = row.tutorId.trim() == needle.tutorId.trim();
      final sameDate = row.dateLabel.trim() == needle.dateLabel.trim();
      final sameTime = row.timeLabel.trim() == needle.timeLabel.trim();
      final sameAmount = (row.totalPrice - needle.totalPrice).abs() < 0.01;
      return sameTutor && sameDate && sameTime && sameAmount;
    });
  }

  BookingRecord? _toBookingRecord(dynamic item) {
    if (item is! Map) return null;
    final map = Map<String, dynamic>.from(item as Map);
    final tutorRaw = map['tutorId'];
    final tutor = tutorRaw is Map ? Map<String, dynamic>.from(tutorRaw as Map) : <String, dynamic>{};

    final tutorId = (tutor['_id'] ?? tutor['id'] ?? map['tutorId'] ?? '').toString();
    final tutorName =
        (tutor['fullName'] ?? tutor['name'] ?? tutor['username'] ?? 'Tutor').toString();
    final tutorImage = _normalizeImageUrl((tutor['profileImage'] ?? tutor['avatar'] ?? '').toString());

    final amountRaw = map['amount'] ?? 0;
    final totalPrice = amountRaw is num
        ? amountRaw.toDouble()
        : double.tryParse(amountRaw.toString()) ?? 0;

    final durationRaw = map['duration'] ?? 60;
    final durationMinutes = int.tryParse(durationRaw.toString()) ?? 60;

    var bookingStatus = (map['bookingStatus'] ?? '').toString();
    final paymentStatus = (map['paymentStatus'] ?? '').toString();

    final normalizedBookingStatus = bookingStatus.toLowerCase();
    final normalizedPaymentStatus = paymentStatus.toLowerCase();

    if (normalizedBookingStatus == 'cancelled' || normalizedBookingStatus == 'canceled') {
      bookingStatus = 'pending';
    } else if (normalizedPaymentStatus == 'paid' && normalizedBookingStatus != 'completed') {
      bookingStatus = 'confirmed';
    }

    final isCompleted = bookingStatus.toLowerCase() == 'completed';

    final createdAt =
        DateTime.tryParse((map['createdAt'] ?? '').toString()) ?? DateTime.now();

    return BookingRecord(
      tutorId: tutorId,
      tutorName: tutorName,
      tutorImage: tutorImage,
      dateLabel: (map['date'] ?? '').toString(),
      timeLabel: (map['time'] ?? '').toString(),
      sessionRate: durationMinutes > 0 ? (totalPrice * 60 / durationMinutes) : totalPrice,
      durationMinutes: durationMinutes,
      totalPrice: totalPrice,
      paymentMethod: (map['paymentMethod'] ?? 'esewa').toString(),
      isCompleted: isCompleted,
      bookingStatus: bookingStatus,
      paymentStatus: paymentStatus,
      createdAt: createdAt,
    );
  }

  String _normalizeImageUrl(String value) {
    final url = value.trim();
    if (url.isEmpty) return '';

    if (url.startsWith('http://') || url.startsWith('https://')) {
      if (url.contains('localhost')) {
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
      }
      return url;
    }

    if (url.startsWith('/')) return '${ApiEndpoints.mediaServerUrl}$url';
    return '${ApiEndpoints.mediaServerUrl}/$url';
  }

  @override
  void dispose() {
    _shakeSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Booking History'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF111111) : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Search tutor',
                    hintStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: isDark ? Colors.white70 : null),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorText != null
                  ? Center(child: Text(_errorText!))
                  : ValueListenableBuilder<List<BookingRecord>>(
                valueListenable: BookingStore.bookings,
                builder: (context, bookings, _) {
                  final filtered = bookings.where((booking) {
                    if (_query.isEmpty) return true;
                    return booking.tutorName.toLowerCase().contains(_query);
                  }).toList();

                  final upcoming = filtered.where((booking) => !booking.isCompleted).toList();
                  final completed = filtered.where((booking) => booking.isCompleted).toList();

                  return TabBarView(
                    children: [
                      _BookingList(bookings: upcoming, isCompleted: false),
                      _BookingList(bookings: completed, isCompleted: true),
                    ],
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

class _BookingList extends StatelessWidget {
  const _BookingList({required this.bookings, required this.isCompleted});

  final List<BookingRecord> bookings;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Text(isCompleted ? 'No completed bookings yet' : 'No upcoming bookings yet'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: bookings.length,
      itemBuilder: (context, index) => _BookingCard(booking: bookings[index]),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final BookingRecord booking;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusText = booking.bookingStatus?.trim().isNotEmpty == true
      ? booking.bookingStatus!
      : 'confirmed';
    final isSuccess = statusText.toLowerCase() == 'confirmed' ||
      statusText.toLowerCase() == 'completed';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _BookingAvatar(imageUrl: booking.tutorImage),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking.tutorName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${booking.dateLabel} at ${booking.timeLabel}',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${booking.durationMinutes} min • ${booking.paymentMethod}',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSuccess ? Colors.green.shade100 : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      statusText[0].toUpperCase() + statusText.substring(1),
                      style: TextStyle(
                        color: isSuccess ? Colors.green : Colors.orange.shade800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'Rs ${booking.totalPrice.toStringAsFixed(0)}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingAvatar extends StatelessWidget {
  const _BookingAvatar({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.trim().isEmpty) {
      return const CircleAvatar(
        radius: 26,
        backgroundColor: Colors.grey,
        child: Icon(Icons.person, color: Colors.white),
      );
    }

    return CircleAvatar(
      radius: 26,
      backgroundImage: NetworkImage(imageUrl),
      onBackgroundImageError: (_, __) {},
      backgroundColor: Colors.grey.shade300,
      child: imageUrl.trim().isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
    );
  }
}

