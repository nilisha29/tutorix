// import 'package:flutter/material.dart';
// import 'package:tutorix/core/widgets/category_chip.dart';
// import 'package:tutorix/core/widgets/tutor_card.dart';
// import 'package:tutorix/core/widgets/recommended_card.dart';

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Top bar
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: const [
//                   CircleAvatar(radius: 22, backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)),
//                   Row(
//                     children: [
//                       Icon(Icons.search, size: 26),
//                       SizedBox(width: 16),
//                       Icon(Icons.notifications_none, size: 26),
//                     ],
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),

//               // Greeting
//               const Text("Hello, Sophia!", style: TextStyle(fontSize: 14, color: Colors.black54)),
//               const SizedBox(height: 6),
//               const Text("Find your best\ntutor and teacher", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 20),

//               // Categories
//               SizedBox(
//                 height: 50,
//                 child: ListView(
//                   scrollDirection: Axis.horizontal,
//                   children: const [
//                     CategoryChip(title: "Graphic design", active: true),
//                     CategoryChip(title: "Biology", active: false),
//                     CategoryChip(title: "Mathematics", active: false),
//                     CategoryChip(title: "English", active: false),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // Top Tutors
//               const Text("Top Tutors", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 12),
//               SizedBox(
//                 height: 220,
//                 child: ListView(
//                   scrollDirection: Axis.horizontal,
//                   children: const [
//                     TutorCard(name: "Nisha Basnet", subject: "Mathematics", rating: "4.8"),
//                     TutorCard(name: "Rita Rai", subject: "Physics", rating: "4.8"),
//                     TutorCard(name: "Nabin", subject: "Biology", rating: "4.8"),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),

//               // Recommended
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: const [
//                   Text("Recommended", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   Text("View all", style: TextStyle(color: Colors.green)),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               const RecommendedCard(name: "Anita Sharma", subject: "Physics & Chemistry Expert"),
//               const SizedBox(height: 12),
//               const RecommendedCard(name: "Khashayar Shomali", subject: "Chemistry"),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:tutorix/core/widgets/category_chip.dart';
// import 'package:tutorix/core/widgets/tutor_card.dart';
// import 'package:tutorix/core/widgets/recommended_card.dart';
// import 'package:tutorix/features/auth/presentation/view_model/auth_viewmodel.dart';

// class HomePage extends ConsumerWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final authState = ref.watch(authViewModelProvider);

//     // Use profile image if available, else fallback to default
//     ImageProvider? profileImage;
//     if (authState.authEntity?.profilePicture != null) {
//       profileImage = FileImage(File(authState.authEntity!.profilePicture!));
//     }

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Top bar
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   CircleAvatar(
//                     radius: 22,
//                     backgroundColor: Colors.grey,
//                     backgroundImage: profileImage,
//                     child: profileImage == null
//                         ? const Icon(Icons.person, color: Colors.white)
//                         : null,
//                   ),
//                   Row(
//                     children: const [
//                       Icon(Icons.search, size: 26),
//                       SizedBox(width: 16),
//                       Icon(Icons.notifications_none, size: 26),
//                     ],
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),

//               // Greeting
//               Text(
//                 "Hello, ${authState.authEntity?.fullName ?? "User"}!",
//                 style: const TextStyle(fontSize: 14, color: Colors.black54),
//               ),
//               const SizedBox(height: 6),
//               const Text(
//                 "Find your best\ntutor and teacher",
//                 style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 20),

//               // Categories
//               SizedBox(
//                 height: 50,
//                 child: ListView(
//                   scrollDirection: Axis.horizontal,
//                   children: const [
//                     CategoryChip(title: "Graphic design", active: true),
//                     CategoryChip(title: "Biology", active: false),
//                     CategoryChip(title: "Mathematics", active: false),
//                     CategoryChip(title: "English", active: false),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // Top Tutors
//               const Text(
//                 "Top Tutors",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 12),
//               SizedBox(
//                 height: 220,
//                 child: ListView(
//                   scrollDirection: Axis.horizontal,
//                   children: const [
//                     TutorCard(name: "Nisha Basnet", subject: "Mathematics", rating: "4.8"),
//                     TutorCard(name: "Rita Rai", subject: "Physics", rating: "4.8"),
//                     TutorCard(name: "Nabin", subject: "Biology", rating: "4.8"),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),

//               // Recommended
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: const [
//                   Text("Recommended", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   Text("View all", style: TextStyle(color: Colors.green)),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               const RecommendedCard(name: "Anita Sharma", subject: "Physics & Chemistry Expert"),
//               const SizedBox(height: 12),
//               const RecommendedCard(name: "Khashayar Shomali", subject: "Chemistry"),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:tutorix/core/widgets/category_chip.dart';
// import 'package:tutorix/core/widgets/tutor_card.dart';
// import 'package:tutorix/core/widgets/recommended_card.dart';
// import 'package:tutorix/features/auth/presentation/view_model/auth_viewmodel.dart';

// class HomePage extends ConsumerWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final authState = ref.watch(authViewModelProvider);

//     ImageProvider? profileImage;
//     if (authState.authEntity?.profilePicture != null) {
//       profileImage = FileImage(File(authState.authEntity!.profilePicture!));
//     }

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // 🔹 TOP BAR
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   CircleAvatar(
//                     radius: 22,
//                     backgroundColor: Colors.grey.shade300,
//                     backgroundImage: profileImage,
//                     child: profileImage == null
//                         ? const Icon(Icons.person, color: Colors.white)
//                         : null,
//                   ),
//                   Row(
//                     children: const [
//                       Icon(Icons.search, size: 26),
//                       SizedBox(width: 16),
//                       Icon(Icons.notifications_none, size: 26),
//                     ],
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 16),

//               // 🔹 GREETING
//               Text(
//                 "Hello, ${authState.authEntity?.fullName ?? "User"}!",
//                 style: const TextStyle(
//                   fontSize: 14,
//                   color: Colors.black54,
//                 ),
//               ),

//               const SizedBox(height: 6),

//               const Text(
//                 "Find your best\ntutor and teacher",
//                 style: TextStyle(
//                   fontSize: 26,
//                   fontWeight: FontWeight.bold,
//                   height: 1.2,
//                 ),
//               ),

//               const SizedBox(height: 20),

//               // 🔹 CATEGORIES
//               SizedBox(
//                 height: 42,
//                 child: ListView(
//                   scrollDirection: Axis.horizontal,
//                   children: const [
//                     CategoryChip(title: "Graphic design", active: true),
//                     CategoryChip(title: "Biology", active: false),
//                     CategoryChip(title: "Mathematics", active: false),
//                     CategoryChip(title: "English", active: false),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 28),

//               // 🔹 TOP TUTORS
//               const Text(
//                 "Top Tutors",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),

//               const SizedBox(height: 14),

//               SizedBox(
//                 height: 210,
//                 child: ListView(
//                   scrollDirection: Axis.horizontal,
//                   children: const [
//                     TutorCard(
//                       name: "Nisha Basnet",
//                       subject: "Mathematics",
//                       rating: "4.8",
//                     ),
//                     TutorCard(
//                       name: "Rita Rai",
//                       subject: "Physics",
//                       rating: "4.8",
//                     ),
//                     TutorCard(
//                       name: "Nabin",
//                       subject: "Biology",
//                       rating: "4.8",
//                     ),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // 🔹 RECOMMENDED HEADER
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: const [
//                   Text(
//                     "Recommended",
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   Text(
//                     "View all",
//                     style: TextStyle(
//                       color: Colors.green,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 14),

//               // 🔹 RECOMMENDED LIST
//               const RecommendedCard(
//                 name: "Anita Sharma",
//                 subject: "Physics & Chemistry Expert",
//               ),
//               const SizedBox(height: 12),
//               const RecommendedCard(
//                 name: "Khashayar Shomali",
//                 subject: "Chemistry",
//               ),

//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:tutorix/core/widgets/category_chip.dart';
// import 'package:tutorix/core/widgets/tutor_card.dart';
// import 'package:tutorix/core/widgets/recommended_card.dart';
// import 'package:tutorix/features/auth/presentation/view_model/auth_viewmodel.dart';

// class HomePage extends ConsumerWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final authState = ref.watch(authViewModelProvider);

//     ImageProvider? profileImage;
//     if (authState.authEntity?.profilePicture != null) {
//       profileImage = FileImage(File(authState.authEntity!.profilePicture!));
//     }

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // 🔝 TOP BAR
//               Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 24,
//                     backgroundColor: Colors.orange.shade100,
//                     backgroundImage: profileImage,
//                     child: profileImage == null
//                         ? const Icon(Icons.person, color: Colors.orange)
//                         : null,
//                   ),
//                   const SizedBox(width: 12),

//                   // 👋 GREETING
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         "Hello,",
//                         style: TextStyle(fontSize: 13, color: Colors.grey),
//                       ),
//                       Text(
//                         authState.authEntity?.fullName ?? "User",
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),

//                   const Spacer(),

//                   const Icon(Icons.search, size: 26),
//                   const SizedBox(width: 16),
//                   const Icon(Icons.notifications_none, size: 26),
//                 ],
//               ),

//               const SizedBox(height: 24),

//               // 🧠 TITLE
//               const Text(
//                 "Find your best\ntutor and teacher",
//                 style: TextStyle(
//                   fontSize: 26,
//                   fontWeight: FontWeight.bold,
//                   height: 1.2,
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // 📚 CATEGORIES
//               SizedBox(
//                 height: 42,
//                 child: ListView(
//                   scrollDirection: Axis.horizontal,
//                   children: const [
//                     CategoryChip(title: "Graphic design", active: true),
//                     CategoryChip(title: "Biology", active: false),
//                     CategoryChip(title: "Mathematics", active: false),
//                     CategoryChip(title: "English", active: false),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 28),

//               // ⭐ TOP TUTORS
//               const Text(
//                 "Top Tutors",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),

//               const SizedBox(height: 16),

//               SizedBox(
//                 height: 210,
//                 child: ListView(
//                   scrollDirection: Axis.horizontal,
//                   children: const [
//                     TutorCard(name: "Nisha Basnet", subject: "Mathematics", rating: "4.8"),
//                     TutorCard(name: "Rita Rai", subject: "Physics", rating: "4.8"),
//                     TutorCard(name: "Nabin", subject: "Biology", rating: "4.8"),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // 👍 RECOMMENDED
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: const [
//                   Text(
//                     "Recommended",
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   Text(
//                     "View all",
//                     style: TextStyle(color: Colors.green),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 16),

//               const RecommendedCard(
//                 name: "Anita Sharma",
//                 subject: "Physics & Chemistry Expert",
//               ),
//               const SizedBox(height: 12),
//               const RecommendedCard(
//                 name: "Khashayar Shomali",
//                 subject: "Chemistry",
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:tutorix/features/auth/presentation/view_model/auth_viewmodel.dart';
// import 'package:tutorix/core/widgets/category_chip.dart';
// import 'package:tutorix/core/widgets/tutor_card.dart';
// import 'package:tutorix/core/widgets/recommended_card.dart';

// class HomePage extends ConsumerWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final authState = ref.watch(authViewModelProvider);

//     ImageProvider? profileImage;
//     final profileUrl = authState.authEntity?.profilePicture;

//     if (profileUrl != null && profileUrl.startsWith("http")) {
//       profileImage = NetworkImage(profileUrl);
//     }

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // 🔝 TOP BAR
//               Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 24,
//                     backgroundImage: profileImage,
//                     child: profileImage == null
//                         ? const Icon(Icons.person)
//                         : null,
//                   ),
//                   const SizedBox(width: 12),

//                   // 👋 GREETING
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         "Hello,",
//                         style: TextStyle(fontSize: 13, color: Colors.grey),
//                       ),
//                       Text(
//                         authState.authEntity?.fullName ?? "User",
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),

//                   const Spacer(),

//                   const Icon(Icons.search, size: 26),
//                   const SizedBox(width: 16),
//                   const Icon(Icons.notifications_none, size: 26),
//                 ],
//               ),

//               const SizedBox(height: 24),

//               // 🧠 TITLE
//               const Text(
//                 "Find your best\ntutor and teacher",
//                 style: TextStyle(
//                   fontSize: 26,
//                   fontWeight: FontWeight.bold,
//                   height: 1.2,
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // 📚 CATEGORIES
//               SizedBox(
//                 height: 42,
//                 child: ListView(
//                   scrollDirection: Axis.horizontal,
//                   children: const [
//                     CategoryChip(title: "Graphic design", active: true),
//                     CategoryChip(title: "Biology"),
//                     CategoryChip(title: "Mathematics"),
//                     CategoryChip(title: "English"),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 28),

//               // ⭐ TOP TUTORS
//               const Text(
//                 "Top Tutors",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),

//               const SizedBox(height: 16),

//               SizedBox(
//                 height: 210,
//                 child: ListView(
//                   scrollDirection: Axis.horizontal,
//                   children: const [
//                     TutorCard(name: "Nisha Basnet", subject: "Mathematics", rating: "4.8"),
//                     TutorCard(name: "Rita Rai", subject: "Physics", rating: "4.8"),
//                     TutorCard(name: "Nabin", subject: "Biology", rating: "4.8"),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // 👍 RECOMMENDED
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: const [
//                   Text(
//                     "Recommended",
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   Text("View all", style: TextStyle(color: Colors.green)),
//                 ],
//               ),

//               const SizedBox(height: 16),

//               const RecommendedCard(
//                 name: "Anita Sharma",
//                 subject: "Physics & Chemistry Expert",
//               ),
//               const SizedBox(height: 12),
//               const RecommendedCard(
//                 name: "Khashayar Shomali",
//                 subject: "Chemistry",
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:tutorix/core/widgets/category_chip.dart';
// import 'package:tutorix/core/widgets/tutor_card.dart';
// import 'package:tutorix/core/widgets/recommended_card.dart';
// import 'package:tutorix/features/auth/presentation/view_model/auth_viewmodel.dart';


// class HomePage extends ConsumerWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final authState = ref.watch(authViewModelProvider);
//     final authNotifier = ref.read(authViewModelProvider.notifier);

//     ImageProvider? profileImage;

//     if (authState.authEntity?.profilePicture != null) {
//       final url = authState.authEntity!.profilePicture!;
//       profileImage = NetworkImage(url); // Server URL
//     }

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // 🔝 TOP BAR
//               Row(
//                 children: [
//                   CircleAvatar(
//                     radius: 24,
//                     backgroundColor: Colors.orange.shade100,
//                     backgroundImage: profileImage,
//                     child: profileImage == null
//                         ? const Icon(Icons.person, color: Colors.orange)
//                         : null,
//                   ),
//                   const SizedBox(width: 12),

//                   // 👋 GREETING
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         "Hello,",
//                         style: TextStyle(fontSize: 13, color: Colors.grey),
//                       ),
//                       Text(
//                         authState.authEntity?.fullName ?? "User",
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const Spacer(),
//                   const Icon(Icons.search, size: 26),
//                   const SizedBox(width: 16),
//                   const Icon(Icons.notifications_none, size: 26),
//                 ],
//               ),

//               const SizedBox(height: 24),

//               // 🧠 TITLE
//               const Text(
//                 "Find your best\ntutor and teacher",
//                 style: TextStyle(
//                   fontSize: 26,
//                   fontWeight: FontWeight.bold,
//                   height: 1.2,
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // 📚 CATEGORIES
//               SizedBox(
//                 height: 42,
//                 child: ListView(
//                   scrollDirection: Axis.horizontal,
//                   children: const [
//                     CategoryChip(title: "Graphic design", active: true),
//                     CategoryChip(title: "Biology", active: false),
//                     CategoryChip(title: "Mathematics", active: false),
//                     CategoryChip(title: "English", active: false),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 28),

//               // ⭐ TOP TUTORS
//               const Text(
//                 "Top Tutors",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 16),
//               SizedBox(
//                 height: 210,
//                 child: ListView(
//                   scrollDirection: Axis.horizontal,
//                   children: const [
//                     TutorCard(name: "Nisha Basnet", subject: "Mathematics", rating: "4.8"),
//                     TutorCard(name: "Rita Rai", subject: "Physics", rating: "4.8"),
//                     TutorCard(name: "Nabin", subject: "Biology", rating: "4.8"),
//                   ],
//                 ),
//               ),

//               const SizedBox(height: 24),

//               // 👍 RECOMMENDED
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: const [
//                   Text(
//                     "Recommended",
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   Text(
//                     "View all",
//                     style: TextStyle(color: Colors.green),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 16),
//               const RecommendedCard(
//                 name: "Anita Sharma",
//                 subject: "Physics & Chemistry Expert",
//               ),
//               const SizedBox(height: 12),
//               const RecommendedCard(
//                 name: "Khashayar Shomali",
//                 subject: "Chemistry",
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/widgets/category_chip.dart';
import 'package:tutorix/core/widgets/tutor_card.dart';
import 'package:tutorix/core/widgets/recommended_card.dart';
import 'package:tutorix/features/auth/presentation/view_model/auth_viewmodel.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);

    // Determine profile image
    ImageProvider? profileImage;
    final profilePath = authState.profilePicture ?? authState.authEntity?.profilePicture;
    if (profilePath != null && profilePath.isNotEmpty) {
      if (profilePath.startsWith('http')) {
        profileImage = NetworkImage(profilePath);
      } else {
        profileImage = FileImage(File(profilePath));
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔝 TOP BAR
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.orange.shade100,
                    backgroundImage: profileImage,
                    child: profileImage == null
                        ? const Icon(Icons.person, color: Colors.orange)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Hello,",
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      Text(
                        authState.authEntity?.fullName ?? "User",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.search, size: 26),
                  const SizedBox(width: 16),
                  const Icon(Icons.notifications_none, size: 26),
                ],
              ),

              const SizedBox(height: 24),

              // 🧠 TITLE
              const Text(
                "Find your best\ntutor and teacher",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: 24),

              // 📚 CATEGORIES
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    CategoryChip(title: "Graphic design", active: true),
                    CategoryChip(title: "Biology", active: false),
                    CategoryChip(title: "Mathematics", active: false),
                    CategoryChip(title: "English", active: false),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ⭐ TOP TUTORS
              const Text(
                "Top Tutors",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 210,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    TutorCard(name: "Nisha Basnet", subject: "Mathematics", rating: "4.8"),
                    TutorCard(name: "Rita Rai", subject: "Physics", rating: "4.8"),
                    TutorCard(name: "Nabin", subject: "Biology", rating: "4.8"),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 👍 RECOMMENDED
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Recommended",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "View all",
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const RecommendedCard(
                name: "Anita Sharma",
                subject: "Physics & Chemistry Expert",
              ),
              const SizedBox(height: 12),
              const RecommendedCard(
                name: "Khashayar Shomali",
                subject: "Chemistry",
              ),
            ],
          ),
        ),
      ),
    );
  }
}






