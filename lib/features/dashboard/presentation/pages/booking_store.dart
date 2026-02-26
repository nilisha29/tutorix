import 'package:flutter/material.dart';

class BookingRecord {
  BookingRecord({
    required this.tutorName,
    required this.tutorImage,
    required this.dateLabel,
    required this.timeLabel,
    required this.sessionRate,
    required this.durationMinutes,
    required this.totalPrice,
    required this.paymentMethod,
    this.isCompleted = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String tutorName;
  final String tutorImage;
  final String dateLabel;
  final String timeLabel;
  final double sessionRate;
  final int durationMinutes;
  final double totalPrice;
  final String paymentMethod;
  final bool isCompleted;
  final DateTime createdAt;
}

class BookingStore {
  static final ValueNotifier<List<BookingRecord>> bookings =
      ValueNotifier<List<BookingRecord>>(<BookingRecord>[]);

  static void addBooking(BookingRecord booking) {
    bookings.value = <BookingRecord>[booking, ...bookings.value];
  }
}
