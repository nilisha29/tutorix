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
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorix/core/api/api_client.dart';
import 'package:tutorix/core/api/api_endpoints.dart';
import 'package:tutorix/core/widgets/category_chip.dart';
import 'package:tutorix/core/widgets/tutor_card.dart';
import 'package:tutorix/core/widgets/recommended_card.dart';
import 'package:tutorix/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:tutorix/features/dashboard/presentation/pages/tutor_profile_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _loadingTutors = true;
  String? _tutorError;
  List<_HomeTutorItem> _topTutors = const [];
  List<_HomeTutorItem> _recommendedTutors = const [];

  @override
  void initState() {
    super.initState();
    _fetchHomeTutors();
  }

  Future<void> _fetchHomeTutors() async {
    setState(() {
      _loadingTutors = true;
      _tutorError = null;
    });

    final apiClient = ref.read(apiClientProvider);

    try {
      final response = await _requestTutors(apiClient)
          .timeout(const Duration(seconds: 15));
      final allTutors = _extractTutorMaps(response.data)
          .map(_HomeTutorItem.fromJson)
          .toList();

      allTutors.sort((a, b) => b.ratingValue.compareTo(a.ratingValue));

      if (!mounted) return;

      setState(() {
        _topTutors = allTutors.take(6).toList();
        _recommendedTutors = allTutors.skip(1).take(4).toList();
        if (_recommendedTutors.isEmpty) {
          _recommendedTutors = allTutors.take(4).toList();
        }
        _loadingTutors = false;
      });
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        _loadingTutors = false;
        _tutorError = 'Request timed out. Please try again.';
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingTutors = false;
        _tutorError = e.response?.data is Map<String, dynamic>
            ? e.response?.data['message']?.toString()
            : e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingTutors = false;
        _tutorError = 'Failed to load tutors';
      });
    }
  }

  Future<Response<dynamic>> _requestTutors(ApiClient apiClient) async {
    final candidatePaths = <String>[
      '/tutors',
      '/users/tutors',
      '/auth/tutors',
      '/teacher/tutors',
      ApiEndpoints.users,
    ];

    DioException? lastError;

    for (final path in candidatePaths) {
      try {
        return await apiClient.get(path, queryParameters: const {'role': 'tutor'});
      } on DioException catch (e) {
        lastError = e;
        try {
          return await apiClient.get(path);
        } on DioException catch (e2) {
          lastError = e2;
          continue;
        }
      }
    }

    throw lastError ??
        DioException(
          requestOptions: RequestOptions(path: candidatePaths.first),
          message: 'No tutor endpoint found on backend',
        );
  }

  List<Map<String, dynamic>> _extractTutorMaps(dynamic rawData) {
    final source = rawData is Map<String, dynamic> ? rawData['data'] : rawData;
    if (source is! List) return [];

    return source
        .whereType<Map>()
        .map((raw) {
          final map = <String, dynamic>{};
          raw.forEach((key, value) {
            if (key != null) {
              map[key.toString()] = value;
            }
          });
          return map;
        })
        .where((user) {
          final role = (user['role'] ?? '').toString().toLowerCase();
          return role.isEmpty || role == 'tutor';
        })
        .toList();
  }

  String _normalizeImageUrl(String? url) {
    if (url == null) return '';
    final value = url.trim();
    if (value.isEmpty || value.toLowerCase() == 'null') return '';

    if (value.startsWith('http://localhost:')) {
      return value.replaceFirst('http://localhost:', 'http://10.0.2.2:');
    }
    if (value.startsWith('http')) return value;

    if (value.startsWith('/')) {
      return '${ApiEndpoints.mediaServerUrl}$value';
    }
    return '${ApiEndpoints.mediaServerUrl}/$value';
  }


  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);

    // Determine profile image
    final profilePath = authState.profilePicture ?? authState.authEntity?.profilePicture;
    print('[DEBUG HOME] Profile Path: $profilePath'); // Debug log
    
    Widget getProfileAvatar() {
      if (profilePath == null || profilePath.isEmpty) {
        return CircleAvatar(
          radius: 24,
          backgroundColor: Colors.orange.shade100,
          child: const Icon(Icons.person, color: Colors.orange),
        );
      }
      
      if (profilePath.startsWith('http')) {
        print('[DEBUG HOME] Using NetworkImage for: $profilePath');
        return CircleAvatar(
          radius: 24,
          backgroundColor: Colors.orange.shade100,
          backgroundImage: NetworkImage(profilePath),
          onBackgroundImageError: (exception, stackTrace) {
            print('[DEBUG HOME] Failed to load network image: $exception');
          },
        );
      } else {
        print('[DEBUG HOME] Using FileImage for: $profilePath');
        return CircleAvatar(
          radius: 24,
          backgroundColor: Colors.orange.shade100,
          backgroundImage: FileImage(File(profilePath)),
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // 🔝 TOP BAR
              Row(
                children: [
                  getProfileAvatar(),
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
                height: 245,
                child: _loadingTutors
                    ? const Center(child: CircularProgressIndicator())
                    : _topTutors.isEmpty
                        ? const Center(child: Text('No top tutors available'))
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _topTutors.length,
                            itemBuilder: (context, index) {
                              final tutor = _topTutors[index];
                              return TutorCard(
                                name: tutor.name,
                                subject: tutor.subject,
                                rating: tutor.rating,
                                profileImageUrl: _normalizeImageUrl(tutor.profileImage),
                                onViewProfile: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TutorProfilePage(
                                        tutorId: tutor.id,
                                        initialName: tutor.name,
                                        initialSubject: tutor.subject,
                                        initialRating: tutor.rating,
                                        initialProfileImage:
                                            _normalizeImageUrl(tutor.profileImage),
                                        initialPrice: tutor.price,
                                        initialAbout: tutor.about,
                                        initialExperienceYears: tutor.experienceYears,
                                        initialSubjects: tutor.subjectList,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
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
              if (_loadingTutors)
                const Center(child: CircularProgressIndicator())
              else if (_recommendedTutors.isEmpty)
                Text(_tutorError ?? 'No recommended tutors available')
              else
                ..._recommendedTutors.map(
                  (tutor) => RecommendedCard(
                    name: tutor.name,
                    subject: tutor.subject,
                    rating: tutor.rating,
                    price: tutor.price,
                    profileImageUrl: _normalizeImageUrl(tutor.profileImage),
                    onViewProfile: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TutorProfilePage(
                            tutorId: tutor.id,
                            initialName: tutor.name,
                            initialSubject: tutor.subject,
                            initialRating: tutor.rating,
                            initialProfileImage: _normalizeImageUrl(tutor.profileImage),
                            initialPrice: tutor.price,
                            initialAbout: tutor.about,
                            initialExperienceYears: tutor.experienceYears,
                            initialSubjects: tutor.subjectList,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeTutorItem {
  const _HomeTutorItem({
    required this.id,
    required this.name,
    required this.subject,
    required this.rating,
    required this.ratingValue,
    required this.profileImage,
    required this.price,
    required this.about,
    required this.experienceYears,
    required this.subjectList,
  });

  final String id;
  final String name;
  final String subject;
  final String rating;
  final double ratingValue;
  final String profileImage;
  final String price;
  final String about;
  final String experienceYears;
  final List<String> subjectList;

  static String _extractImage(dynamic raw) {
    if (raw == null) return '';
    if (raw is String) return raw.trim();
    if (raw is Map) {
      final url = raw['url'] ?? raw['secure_url'] ?? raw['path'] ?? raw['location'];
      return url?.toString().trim() ?? '';
    }
    return raw.toString().trim();
  }

  factory _HomeTutorItem.fromJson(Map<String, dynamic> json) {
    final id = (json['_id'] ?? json['id'] ?? '').toString();
    final name = (json['fullName'] ?? json['name'] ?? 'Tutor').toString();
    final subjects = json['subjects'];
    final languages = json['languages'];
    final tags = json['tags'];

    final subjectList = <String>[];
    if (subjects is List && subjects.isNotEmpty) {
      subjectList.addAll(subjects.map((e) => e.toString()));
    } else if (languages is List && languages.isNotEmpty) {
      subjectList.addAll(languages.map((e) => e.toString()));
    } else if (tags is List && tags.isNotEmpty) {
      subjectList.addAll(tags.map((e) => e.toString()));
    }

    final subjectText = subjectList.isNotEmpty
        ? subjectList.join(', ')
        : (json['bio'] ?? 'Tutor').toString();

    final ratingRaw = json['averageRating'] ?? json['rating'] ?? 4.8;
    final ratingValue = ratingRaw is num
        ? ratingRaw.toDouble()
        : double.tryParse(ratingRaw.toString()) ?? 4.8;

    final priceRaw = json['hourlyRate'] ?? json['pricePerHour'] ?? json['price'] ?? 60;
    final priceValue = priceRaw is num
        ? priceRaw.toDouble()
        : double.tryParse(priceRaw.toString()) ?? 60;

    final expRaw =
        json['experienceYears'] ?? json['experience'] ?? json['yearsOfExperience'];
    final expValue = expRaw is num
        ? expRaw.toInt()
        : int.tryParse(expRaw?.toString() ?? '') ?? 5;

    final imageValue = _extractImage(
      json['profileImage'] ??
          json['profilePicture'] ??
          json['avatar'] ??
          json['image'] ??
          json['photo'],
    );

    return _HomeTutorItem(
      id: id,
      name: name,
      subject: subjectText,
      rating: ratingValue.toStringAsFixed(1),
      ratingValue: ratingValue,
      profileImage: imageValue,
      price: 'Rs. ${priceValue.toStringAsFixed(0)}/hr',
      about: (json['bio'] ?? json['about'] ?? '').toString(),
      experienceYears: '$expValue Years',
      subjectList: subjectList,
    );
  }
}






