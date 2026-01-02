import 'package:flutter/material.dart';

class TutorCard extends StatelessWidget {
  final String name;
  final String subject;
  final String rating;

  const TutorCard({
    super.key,
    required this.name,
    required this.subject,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.person),
          ),
          const SizedBox(height: 10),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(subject, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.star, size: 16, color: Colors.orange),
              const SizedBox(width: 4),
              Text(rating),
            ],
          ),
        ],
      ),
    );
  }
}
