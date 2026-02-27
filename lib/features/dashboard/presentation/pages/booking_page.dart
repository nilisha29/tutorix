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
import 'package:tutorix/features/dashboard/presentation/pages/booking_store.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
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
              child: ValueListenableBuilder<List<BookingRecord>>(
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
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Confirmed',
                      style: TextStyle(color: Colors.green, fontSize: 12),
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

