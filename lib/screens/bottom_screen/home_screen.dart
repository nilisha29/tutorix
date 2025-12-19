// import 'package:flutter/material.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox.expand(
//       child: Center(
//         child: Text('Welcome to the Home Screen')
//       )
//     );
//   }
// }


import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ================= TOP BAR =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.person, color: Colors.white),
                  ),

                  Row(
                    children: const [
                      Icon(Icons.search, size: 26),
                      SizedBox(width: 16),
                      Icon(Icons.notifications_none, size: 26),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 16),

              // ================= GREETING =================
              const Text(
                "Hello, Sophia!",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),

              const SizedBox(height: 6),

              const Text(
                "Find your best\ntutor and teacher",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // ================= CATEGORY =================
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    categoryChip("Graphic design", true),
                    categoryChip("Biology", false),
                    categoryChip("Mathematics", false),
                    categoryChip("English", false),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ================= TOP TUTORS =================
              const Text(
                "Top Tutors",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 220,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    tutorCard("Nisha Basnet", "Mathematics", "4.8"),
                    tutorCard("Rita Rai", "Physics", "4.8"),
                    tutorCard("Nabin", "Biology", "4.8"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ================= RECOMMENDED =================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    "Recommended",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "View all",
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              recommendedCard("Anita Sharma", "Physics & Chemistry Expert"),
              const SizedBox(height: 12),
              recommendedCard("Khashayar Shomali", "Chemistry"),
            ],
          ),
        ),
      ),
    );
  }

  // ================= CATEGORY CHIP =================
  Widget categoryChip(String title, bool active) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: active ? Colors.green : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(25),
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: TextStyle(
          color: active ? Colors.white : Colors.black54,
        ),
      ),
    );
  }

  // ================= TUTOR CARD =================
  Widget tutorCard(String name, String subject, String rating) {
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
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(
            subject,
            style: const TextStyle(color: Colors.black54),
          ),
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

  // ================= RECOMMENDED CARD =================
  Widget recommendedCard(String name, String subject) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
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
              Text(
                name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subject,
                style: const TextStyle(color: Colors.black54),
              ),
              const Text(
                "Per hour: Rs 100",
                style: TextStyle(color: Colors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
