import 'package:flutter/material.dart';

class RecommendedCard extends StatelessWidget {
  final String name;
  final String subject;

  const RecommendedCard({
    super.key,
    required this.name,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(subject, style: const TextStyle(color: Colors.black54)),
              const Text("Per hour: Rs 100", style: TextStyle(color: Colors.green)),
            ],
          ),
        ],
      ),
    );
  }
}
