// import 'package:flutter/material.dart';

// class TutorCard extends StatelessWidget {
//   final String name;
//   final String subject;
//   final String rating;

//   const TutorCard({
//     super.key,
//     required this.name,
//     required this.subject,
//     required this.rating,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 160,
//       margin: const EdgeInsets.only(right: 12),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.orange.shade100,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const CircleAvatar(
//             radius: 30,
//             backgroundColor: Colors.white,
//             child: Icon(Icons.person),
//           ),
//           const SizedBox(height: 10),
//           Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
//           Text(subject, style: const TextStyle(color: Colors.black54)),
//           const SizedBox(height: 6),
//           Row(
//             children: [
//               const Icon(Icons.star, size: 16, color: Colors.orange),
//               const SizedBox(width: 4),
//               Text(rating),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';

// class TutorCard extends StatelessWidget {
//   final String name;
//   final String subject;
//   final String rating;

//   const TutorCard({
//     super.key,
//     required this.name,
//     required this.subject,
//     required this.rating,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Row(
//           children: [
//             const CircleAvatar(
//               radius: 28,
//               child: Icon(Icons.person),
//             ),
//             const SizedBox(width: 12),

//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Text(
//                         name,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       const Spacer(),
//                       const Icon(Icons.star,
//                           color: Colors.orange, size: 16),
//                       Text(rating),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     subject,
//                     style: TextStyle(color: Colors.grey.shade600),
//                   ),
//                   const SizedBox(height: 6),
//                   const Text(
//                     "Rs. 60/hr",
//                     style: TextStyle(color: Colors.red),
//                   ),
//                 ],
//               ),
//             ),

//             ElevatedButton(
//               onPressed: () {},
//               child: const Text("View Profile"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


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
    return SizedBox(
      width: 160, // ⭐ REQUIRED for horizontal ListView
      child: Card(
        margin: const EdgeInsets.only(right: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 36, color: Colors.white),
              ),

              const SizedBox(height: 10),

              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              Text(
                subject,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 6),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    rating,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


