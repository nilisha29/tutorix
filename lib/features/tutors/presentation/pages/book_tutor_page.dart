import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:tutorix/features/payments/presentation/pages/confirm_and_pay_page.dart';

class BookTutorPage extends StatefulWidget {
  const BookTutorPage({
    super.key,
    required this.tutorId,
    required this.tutorName,
    required this.priceLabel,
    required this.tutorProfileImage,
    required this.availabilitySlots,
  });

  final String tutorId;
  final String tutorName;
  final String priceLabel;
  final String tutorProfileImage;
  final List<String> availabilitySlots;

  @override
  State<BookTutorPage> createState() => _BookTutorPageState();
}

class _BookTutorPageState extends State<BookTutorPage> {
  late LinkedHashMap<String, List<String>> _availableDateTimes;
  final LinkedHashMap<String, String> _backendDayByDate = LinkedHashMap<String, String>();
  String? _selectedDateKey;
  String? _selectedTime;
  int _selectedDuration = 60;

  @override
  void initState() {
    super.initState();
    _availableDateTimes = _buildAvailabilityMap(widget.availabilitySlots);
    if (_availableDateTimes.isNotEmpty) {
      _selectedDateKey = _availableDateTimes.keys.first;
    }

    final availableTimes = _timesForSelectedDate();
    if (availableTimes.isNotEmpty) {
      _selectedTime = availableTimes.first;
    }
  }

  double _pricePerHour() {
    final text = widget.priceLabel.replaceAll(',', '');
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(text);
    return double.tryParse(match?.group(1) ?? '') ?? 149.99;
  }

  double _totalPrice() {
    return _pricePerHour() * (_selectedDuration / 60.0);
  }

  LinkedHashMap<String, List<String>> _buildAvailabilityMap(List<String> slots) {
    _backendDayByDate.clear();
    final temp = LinkedHashMap<String, LinkedHashSet<String>>();
    final dayToDate = <String, String>{};
    final fallbackTimes = <String>{};

    void addTimes(String dateLabel, Iterable<String> times) {
      final key = dateLabel.trim();
      if (key.isEmpty) return;
      temp.putIfAbsent(key, () => LinkedHashSet<String>());
      for (final rawTime in times) {
        final normalized = rawTime.trim();
        if (normalized.isNotEmpty) {
          temp[key]!.add(normalized);
        }
      }
    }

    for (final rawSlot in slots) {
      final slot = rawSlot.trim();
      if (slot.isEmpty) continue;

      final normalized = slot.replaceAll('—', '-');
      final parts = normalized.split(':');

      if (parts.length >= 2) {
        final left = parts.first.trim();
        final right = parts.sublist(1).join(':').trim();
        final rightTimes = _extractTimesFromText(right);
        final rightDate = _extractDateLabelFromText(right);

        if (_isDayLabel(left)) {
          if (rightDate != null) {
            dayToDate[left.toLowerCase()] = rightDate;
            _backendDayByDate[rightDate] = _toShortDayLabel(left);
            temp.putIfAbsent(rightDate, () => LinkedHashSet<String>());
          }

          if (rightTimes.isNotEmpty) {
            final resolvedDate = dayToDate[left.toLowerCase()] ?? left;
            if (_isDayLabel(left)) {
              _backendDayByDate[resolvedDate] = _toShortDayLabel(left);
            }
            addTimes(resolvedDate, rightTimes);
            continue;
          }
        }

        if (_looksLikeDateOrDay(left) && rightTimes.isNotEmpty) {
          if (_isDayLabel(left)) {
            _backendDayByDate[left] = _toShortDayLabel(left);
          }
          addTimes(left, rightTimes);
          continue;
        }
      }

      final dateFromWhole = _extractDateLabelFromText(normalized);
      final timesFromWhole = _extractTimesFromText(normalized);

      if (dateFromWhole != null) {
        final dayFromText = _extractDayLabelFromText(normalized);
        if (dayFromText != null) {
          _backendDayByDate[dateFromWhole] = dayFromText;
        }
        temp.putIfAbsent(dateFromWhole, () => LinkedHashSet<String>());
        if (timesFromWhole.isNotEmpty) {
          addTimes(dateFromWhole, timesFromWhole);
        }
        continue;
      }

      if (timesFromWhole.isNotEmpty) {
        fallbackTimes.addAll(timesFromWhole);
      }
    }

    if (temp.isEmpty && fallbackTimes.isNotEmpty) {
      temp['Available'] = LinkedHashSet<String>.from(fallbackTimes);
    }

    final result = LinkedHashMap<String, List<String>>();
    for (final entry in temp.entries) {
      result[entry.key] = entry.value.toList();
    }
    return result;
  }

  bool _looksLikeDateOrDay(String value) {
    final lower = value.toLowerCase();
    if (_isDayLabel(value)) {
      return true;
    }
    if (RegExp(r'^\d{4}[-/]\d{1,2}[-/]\d{1,2}$').hasMatch(lower)) {
      return true;
    }
    if (RegExp(r'^\d{1,2}[-/]\d{1,2}([-/]\d{2,4})?$').hasMatch(lower)) {
      return true;
    }
    if (RegExp(r'^\d{1,2}\s+(jan|feb|mar|apr|may|jun|jul|aug|sep|sept|oct|nov|dec)([a-z]*)[,]?\s*\d{0,4}$').hasMatch(lower)) {
      return true;
    }
    if (RegExp(r'^(jan|feb|mar|apr|may|jun|jul|aug|sep|sept|oct|nov|dec)([a-z]*)\s+\d{1,2}([,]\s*\d{2,4})?$').hasMatch(lower)) {
      return true;
    }
    return false;
  }

  bool _isDayLabel(String value) {
    final lower = value.toLowerCase().trim();
    return RegExp(
      r'^(mon|monday|tue|tues|tuesday|wed|wednesday|thu|thur|thurs|thursday|fri|friday|sat|saturday|sun|sunday)$',
    ).hasMatch(lower);
  }

  String? _extractDateLabelFromText(String text) {
    final value = text.trim();
    if (value.isEmpty) return null;

    final iso = RegExp(r'\b\d{4}[-/]\d{1,2}[-/]\d{1,2}\b').firstMatch(value);
    if (iso != null) return iso.group(0)?.trim();

    final monthDayYear = RegExp(
      r'\b(?:jan|feb|mar|apr|may|jun|jul|aug|sep|sept|oct|nov|dec)[a-z]*\s+\d{1,2}(?:,\s*\d{2,4})?\b',
      caseSensitive: false,
    ).firstMatch(value);
    if (monthDayYear != null) return monthDayYear.group(0)?.trim();

    final dayMonthYear = RegExp(
      r'\b\d{1,2}\s+(?:jan|feb|mar|apr|may|jun|jul|aug|sep|sept|oct|nov|dec)[a-z]*(?:\s+\d{2,4})?\b',
      caseSensitive: false,
    ).firstMatch(value);
    if (dayMonthYear != null) return dayMonthYear.group(0)?.trim();

    final slashDate = RegExp(r'\b\d{1,2}[-/]\d{1,2}(?:[-/]\d{2,4})?\b').firstMatch(value);
    if (slashDate != null) return slashDate.group(0)?.trim();

    if (_isDayLabel(value)) return value;
    return null;
  }

  List<String> _extractTimesFromText(String text) {
    final matches = RegExp(
      r'\b(?:[01]?\d|2[0-3]):[0-5]\d(?:\s*[ap]m)?\b|\b(?:1[0-2]|0?[1-9])\s*[ap]m\b',
      caseSensitive: false,
    ).allMatches(text);

    final times = <String>[];
    for (final match in matches) {
      final value = (match.group(0) ?? '').trim();
      if (value.isNotEmpty && !times.contains(value)) {
        times.add(value);
      }
    }

    return times;
  }

  List<String> _timesForSelectedDate() {
    if (_selectedDateKey == null) return const [];
    return _availableDateTimes[_selectedDateKey] ?? const [];
  }

  String _toShortDayLabel(String raw) {
    final lower = raw.trim().toLowerCase();
    if (lower.startsWith('mon')) return 'Mon';
    if (lower.startsWith('tue')) return 'Tue';
    if (lower.startsWith('wed')) return 'Wed';
    if (lower.startsWith('thu')) return 'Thu';
    if (lower.startsWith('fri')) return 'Fri';
    if (lower.startsWith('sat')) return 'Sat';
    if (lower.startsWith('sun')) return 'Sun';
    return raw.trim();
  }

  String? _extractDayLabelFromText(String raw) {
    final text = raw.toLowerCase();
    final match = RegExp(
      r'\b(mon|monday|tue|tues|tuesday|wed|wednesday|thu|thur|thurs|thursday|fri|friday|sat|saturday|sun|sunday)\b',
    ).firstMatch(text);
    if (match == null) return null;
    return _toShortDayLabel(match.group(0) ?? '');
  }

  String _dayLabelForDateKey(String dateKey) {
    final fromBackend = _backendDayByDate[dateKey];
    if (fromBackend != null && fromBackend.trim().isNotEmpty) {
      return fromBackend.trim();
    }

    if (_isDayLabel(dateKey)) {
      return _toShortDayLabel(dateKey);
    }

    final parsed = DateTime.tryParse(dateKey.trim());
    if (parsed != null) {
      const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return names[parsed.weekday - 1];
    }

    final fromText = _extractDayLabelFromText(dateKey);
    if (fromText != null) return fromText;
    return 'Day';
  }

  String _formatDateLabel(String? label) {
    if (label == null || label.trim().isEmpty) return 'Not selected';
    final day = _dayLabelForDateKey(label);
    final parsed = DateTime.tryParse(label.trim());
    if (parsed == null) {
      if (_isDayLabel(label) || day == 'Day') return label;
      return '$day, $label';
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '$day, ${months[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
  }

  String _monthYearLabel() {
    DateTime? parsed;
    if (_selectedDateKey != null) {
      parsed = DateTime.tryParse(_selectedDateKey!.trim());
    }

    if (parsed == null) {
      for (final key in _availableDateTimes.keys) {
        final value = DateTime.tryParse(key.trim());
        if (value != null) {
          parsed = value;
          break;
        }
      }
    }

    if (parsed == null) return 'Available Dates';

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[parsed.month - 1]} ${parsed.year}';
  }

  String _dateChipLabel(String dateKey) {
    final parsed = DateTime.tryParse(dateKey.trim());
    if (parsed != null) return '${parsed.day}';

    final dayNumber = RegExp(r'\b(\d{1,2})\b').firstMatch(dateKey.trim());
    if (dayNumber != null) {
      return dayNumber.group(1) ?? dateKey.trim();
    }

    final short = dateKey.trim();
    if (short.length <= 2) return short;
    return short.substring(0, 2);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final availableDates = _availableDateTimes.keys.toList();
    final availableTimes = _timesForSelectedDate();

    if (_selectedTime != null && !availableTimes.contains(_selectedTime)) {
      _selectedTime = availableTimes.isNotEmpty ? availableTimes.first : null;
    }

    final total = _totalPrice();
    final canBook = _selectedDateKey != null && _selectedTime != null;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF1F3F5),
      appBar: AppBar(
        title: const Text('Select Date & Time'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF111111) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? Colors.white24 : const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.tutorName,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Rs ${_pricePerHour().toStringAsFixed(0)} / hr',
                            style: const TextStyle(fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: widget.tutorProfileImage.trim().isNotEmpty
                          ? NetworkImage(widget.tutorProfileImage)
                          : null,
                      child: widget.tutorProfileImage.trim().isEmpty
                          ? const Icon(Icons.person, color: Colors.grey)
                          : null,
                      onBackgroundImageError:
                          widget.tutorProfileImage.trim().isNotEmpty ? (_, __) {} : null,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Select Date', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: availableDates.isEmpty
                      ? const Text('No available date from backend')
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(Icons.chevron_left, size: 16, color: Colors.black54),
                                Text(
                                  _monthYearLabel(),
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                                const Icon(Icons.chevron_right, size: 16, color: Colors.black54),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: availableDates
                                  .map(
                                    (dateKey) => InkWell(
                                      onTap: () {
                                        setState(() {
                                          _selectedDateKey = dateKey;
                                          final times = _timesForSelectedDate();
                                          _selectedTime = times.isNotEmpty ? times.first : null;
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        width: 58,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: _selectedDateKey == dateKey
                                              ? const Color(0xFF0C8EDB)
                                              : const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              _dayLabelForDateKey(dateKey),
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: _selectedDateKey == dateKey
                                                    ? Colors.white70
                                                    : Colors.black54,
                                              ),
                                            ),
                                            Text(
                                              _dateChipLabel(dateKey),
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: _selectedDateKey == dateKey
                                                    ? Colors.white
                                                    : Colors.black87,
                                              ),
                                            ),
                                          ],
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
              const Text('Select Time', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              availableTimes.isEmpty
                  ? const Text('No available time for selected date')
                  : Container(
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFD9E1EA)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                        scrollDirection: Axis.horizontal,
                        itemCount: availableTimes.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 4),
                        itemBuilder: (context, index) {
                          final time = availableTimes[index];
                          final selected = _selectedTime == time;
                          return InkWell(
                            onTap: () => setState(() => _selectedTime = time),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18),
                              decoration: BoxDecoration(
                                color: selected ? const Color(0xFF0C8EDB) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                time,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: selected ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 10),
              const Text('Select Duration', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Container(
                height: 30,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFD9E1EA)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [30, 60, 90]
                      .map(
                        (minutes) => Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _selectedDuration = minutes),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _selectedDuration == minutes
                                    ? const Color(0xFF0C8EDB)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$minutes min',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: _selectedDuration == minutes
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              const SizedBox(height: 10),
              const Text('Summary', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              _summaryRow('Session Rate', 'Rs ${_pricePerHour().toStringAsFixed(0)} / hr'),
              _summaryRow('Date', _formatDateLabel(_selectedDateKey)),
              _summaryRow('Time', _selectedTime ?? 'Not selected'),
              _summaryRow('Duration', '$_selectedDuration min'),
              _summaryRow('Total Price', 'Rs ${total.toStringAsFixed(0)}', isBold: true),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: canBook
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ConfirmAndPayPage(
                                tutorId: widget.tutorId,
                                tutorName: widget.tutorName,
                                tutorProfileImage: widget.tutorProfileImage,
                                dateLabel: _formatDateLabel(_selectedDateKey),
                                timeLabel: _selectedTime ?? 'Not selected',
                                sessionRate: _pricePerHour(),
                                durationMinutes: _selectedDuration,
                                totalPrice: total,
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F7F56),
                    foregroundColor: Colors.white,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Proceed to Payment',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String key, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text('$key:')),
          Text(
            value,
            style: TextStyle(fontWeight: isBold ? FontWeight.w700 : FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

