import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:tutorix/features/dashboard/presentation/pages/confirm_and_pay_page.dart';

class BookTutorPage extends StatefulWidget {
  const BookTutorPage({
    super.key,
    required this.tutorName,
    required this.priceLabel,
    required this.tutorProfileImage,
    required this.availabilitySlots,
  });

  final String tutorName;
  final String priceLabel;
  final String tutorProfileImage;
  final List<String> availabilitySlots;

  @override
  State<BookTutorPage> createState() => _BookTutorPageState();
}

class _BookTutorPageState extends State<BookTutorPage> {
  late LinkedHashMap<String, List<String>> _availableDateTimes;
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
            temp.putIfAbsent(rightDate, () => LinkedHashSet<String>());
          }

          if (rightTimes.isNotEmpty) {
            final resolvedDate = dayToDate[left.toLowerCase()] ?? left;
            addTimes(resolvedDate, rightTimes);
            continue;
          }
        }

        if (_looksLikeDateOrDay(left) && rightTimes.isNotEmpty) {
          addTimes(left, rightTimes);
          continue;
        }
      }

      final dateFromWhole = _extractDateLabelFromText(normalized);
      final timesFromWhole = _extractTimesFromText(normalized);

      if (dateFromWhole != null) {
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

  String _formatDateLabel(String? label) {
    if (label == null || label.trim().isEmpty) return 'Not selected';
    final parsed = DateTime.tryParse(label.trim());
    if (parsed == null) return label;

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
    return '${months[parsed.month - 1]} ${parsed.day}, ${parsed.year}';
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
    final availableDates = _availableDateTimes.keys.toList();
    final availableTimes = _timesForSelectedDate();

    if (_selectedTime != null && !availableTimes.contains(_selectedTime)) {
      _selectedTime = availableTimes.isNotEmpty ? availableTimes.first : null;
    }

    final total = _totalPrice();
    final canBook = _selectedDateKey != null && _selectedTime != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: const Text('Select Date & Time'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.tutorName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Rs ${_pricePerHour().toStringAsFixed(0)} / hr',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 14),
              const Text('Select Date', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              availableDates.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text('No available date from backend'),
                    )
                  : Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
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
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Sun', style: TextStyle(fontSize: 9, color: Colors.black54)),
                              Text('Mon', style: TextStyle(fontSize: 9, color: Colors.black54)),
                              Text('Tue', style: TextStyle(fontSize: 9, color: Colors.black54)),
                              Text('Wed', style: TextStyle(fontSize: 9, color: Colors.black54)),
                              Text('Thu', style: TextStyle(fontSize: 9, color: Colors.black54)),
                              Text('Fri', style: TextStyle(fontSize: 9, color: Colors.black54)),
                              Text('Sat', style: TextStyle(fontSize: 9, color: Colors.black54)),
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
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: _selectedDateKey == dateKey
                                            ? const Color(0xFF0C8EDB)
                                            : const Color(0xFFF1F5F9),
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        _dateChipLabel(dateKey),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: _selectedDateKey == dateKey
                                              ? Colors.white
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
              const SizedBox(height: 14),
              const Text('Select Time', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              availableTimes.isEmpty
                  ? const Text('No available time for selected date')
                  : Wrap(
                      spacing: 6,
                      runSpacing: 8,
                      children: availableTimes
                          .map(
                            (time) => _SelectPill(
                              label: time,
                              selected: _selectedTime == time,
                              onTap: () => setState(() => _selectedTime = time),
                            ),
                          )
                          .toList(),
                    ),
              const SizedBox(height: 14),
              const Text('Select Duration', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 8,
                children: [30, 60, 90]
                    .map(
                      (minutes) => _SelectPill(
                        label: '$minutes min',
                        selected: _selectedDuration == minutes,
                        onTap: () => setState(() => _selectedDuration = minutes),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 14),
              const Text('Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              _summaryRow('Session Rate', 'Rs ${_pricePerHour().toStringAsFixed(0)} / hr'),
              _summaryRow('Date', _formatDateLabel(_selectedDateKey)),
              _summaryRow('Time', _selectedTime ?? 'Not selected'),
              _summaryRow('Duration', '$_selectedDuration min'),
              _summaryRow('Total Price', 'Rs ${total.toStringAsFixed(0)}', isBold: true),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: canBook
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ConfirmAndPayPage(
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text(
                    'Proceed to Payment',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Open message composer')), 
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: const Text('Message'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tutor saved')), 
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF0D85A),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
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

class _SelectPill extends StatelessWidget {
  const _SelectPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0C8EDB) : Colors.white,
          border: Border.all(color: const Color(0xFFC9D3E0)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
