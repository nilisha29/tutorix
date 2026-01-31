// import 'package:flutter/material.dart';

// class SearchPage extends StatelessWidget {
//   const SearchPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Search'),
//         backgroundColor: Colors.green,
//       ),
//       body: const Center(
//         child: Text(
//           'Welcome to the Search Page',
//           style: TextStyle(fontSize: 20),
//         ),
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:tutorix/core/widgets/tutor_card.dart';

// class SearchPage extends StatelessWidget {
//   const SearchPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: const BackButton(),
//         title: const Text(
//           "Find Your Tutor",
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // 🔍 Search Bar
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 12),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade200,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const TextField(
//                 decoration: InputDecoration(
//                   hintText: "Search",
//                   border: InputBorder.none,
//                   icon: Icon(Icons.search),
//                   suffixIcon: Icon(Icons.tune),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),

//             // 📋 Tutor List
//             Expanded(
//               child: ListView(
//                 children: const [
//                   TutorCard(
//                     name: "Anita Sharma",
//                     subject: "Physics & Chemistry Expert",
//                     rating: "4.9",
//                   ),
//                   TutorCard(
//                     name: "Rajan Shrestha",
//                     subject: "Certified English Teacher",
//                     rating: "4.9",
//                   ),
//                   TutorCard(
//                     name: "Rachana Thapa",
//                     subject: "Physics, Biology",
//                     rating: "4.9",
//                   ),
//                   TutorCard(
//                     name: "Pranika KC",
//                     subject: "Physics Expert",
//                     rating: "4.9",
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:tutorix/core/widgets/tutor_card.dart';

// class SearchPage extends StatelessWidget {
//   const SearchPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,

//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: const BackButton(color: Colors.black),
//         title: const Text(
//           "Find Your Tutor",
//           style: TextStyle(
//             color: Colors.black,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         centerTitle: true,
//       ),

//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // 🔍 SEARCH BAR
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 14),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade200,
//                 borderRadius: BorderRadius.circular(14),
//               ),
//               child: TextField(
//                 decoration: InputDecoration(
//                   hintText: "Search tutor, subject...",
//                   border: InputBorder.none,
//                   icon: const Icon(Icons.search),
//                   suffixIcon: IconButton(
//                     icon: const Icon(Icons.tune),
//                     onPressed: () {},
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 18),

//             // 📋 SEARCH RESULT LIST
//             Expanded(
//               child: ListView(
//                 children: const [
//                   TutorCard(
//                     name: "Anita Sharma",
//                     subject: "Physics & Chemistry Expert",
//                     rating: "4.9",
//                   ),
//                   TutorCard(
//                     name: "Rajan Shrestha",
//                     subject: "Certified English Teacher",
//                     rating: "4.9",
//                   ),
//                   TutorCard(
//                     name: "Rachana Thapa",
//                     subject: "Physics, Biology",
//                     rating: "4.9",
//                   ),
//                   TutorCard(
//                     name: "Pranika KC",
//                     subject: "Physics Expert",
//                     rating: "4.9",
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text(
          "Find Your Tutor",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.grey.shade100,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔍 Search Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: "Search",
                  border: InputBorder.none,
                  icon: Icon(Icons.search),
                  suffixIcon: Icon(Icons.tune),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 📋 Tutor List
            Expanded(
              child: ListView(
                children: const [
                  TutorCard(
                    name: "Anita Sharma",
                    subject: "Physics & Chemistry Expert",
                    rating: "4.9",
                  ),
                  SizedBox(height: 12),
                  TutorCard(
                    name: "Rajan Shrestha",
                    subject: "Certified English Teacher",
                    rating: "4.9",
                  ),
                  SizedBox(height: 12),
                  TutorCard(
                    name: "Rachana Thapa",
                    subject: "Physics, Biology",
                    rating: "4.9",
                  ),
                  SizedBox(height: 12),
                  TutorCard(
                    name: "Pranika KC",
                    subject: "Physics Expert",
                    rating: "4.9",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------- TUTOR CARD -------------------- */
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            subject,
            style: const TextStyle(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.star, color: Colors.orange, size: 16),
              const SizedBox(width: 4),
              Text(rating),
            ],
          ),
        ],
      ),
    );
  }
}
