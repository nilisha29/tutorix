// import 'package:flutter/material.dart';

// class RecommendedCard extends StatelessWidget {
//   final String name;
//   final String subject;

//   const RecommendedCard({
//     super.key,
//     required this.name,
//     required this.subject,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: const [
//           BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
//         ],
//       ),
//       child: Row(
//         children: [
//           const CircleAvatar(
//             radius: 28,
//             backgroundColor: Colors.grey,
//             child: Icon(Icons.person, color: Colors.white),
//           ),
//           const SizedBox(width: 12),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//               Text(subject, style: const TextStyle(color: Colors.black54)),
//               const Text("Per hour: Rs 100", style: TextStyle(color: Colors.green)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';

class RecommendedCard extends StatelessWidget {
  final String name;
  final String subject;
  final String rating;
  final String price;
  final String? profileImageUrl;
  final VoidCallback? onViewProfile;

  const RecommendedCard({
    super.key,
    required this.name,
    required this.subject,
    this.rating = '4.9',
    this.price = 'Rs. 60/hr',
    this.profileImageUrl,
    this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasImage = profileImageUrl != null && profileImageUrl!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111111) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black45 : Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // 👤 Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey,
            backgroundImage: hasImage ? NetworkImage(profileImageUrl!) : null,
            onBackgroundImageError: hasImage ? (_, __) {} : null,
            child: hasImage ? null : const Icon(Icons.person, color: Colors.white),
          ),

          const SizedBox(width: 12),

          // 📄 Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 2),

                Text(
                  subject,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey.shade600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      rating,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      price,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 👉 Button
          ElevatedButton(
            onPressed: onViewProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "View Profile",
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

