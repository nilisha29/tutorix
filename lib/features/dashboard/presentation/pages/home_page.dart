import 'package:flutter/material.dart';
import 'package:tutorix/core/widgets/category_chip.dart';
import 'package:tutorix/core/widgets/tutor_card.dart';
import 'package:tutorix/core/widgets/recommended_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
              // Top bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  CircleAvatar(radius: 22, backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)),
                  Row(
                    children: [
                      Icon(Icons.search, size: 26),
                      SizedBox(width: 16),
                      Icon(Icons.notifications_none, size: 26),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Greeting
              const Text("Hello, Sophia!", style: TextStyle(fontSize: 14, color: Colors.black54)),
              const SizedBox(height: 6),
              const Text("Find your best\ntutor and teacher", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              // Categories
              SizedBox(
                height: 50,
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
              const SizedBox(height: 24),

              // Top Tutors
              const Text("Top Tutors", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(
                height: 220,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    TutorCard(name: "Nisha Basnet", subject: "Mathematics", rating: "4.8"),
                    TutorCard(name: "Rita Rai", subject: "Physics", rating: "4.8"),
                    TutorCard(name: "Nabin", subject: "Biology", rating: "4.8"),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Recommended
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("Recommended", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("View all", style: TextStyle(color: Colors.green)),
                ],
              ),
              const SizedBox(height: 12),
              const RecommendedCard(name: "Anita Sharma", subject: "Physics & Chemistry Expert"),
              const SizedBox(height: 12),
              const RecommendedCard(name: "Khashayar Shomali", subject: "Chemistry"),
            ],
          ),
        ),
      ),
    );
  }
}