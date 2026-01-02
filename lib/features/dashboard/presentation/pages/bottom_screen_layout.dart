import 'package:flutter/material.dart';
import 'package:tutorix/features/dashboard/presentation/pages/booking_page.dart';
import 'package:tutorix/features/dashboard/presentation/pages/home_page.dart';
import 'package:tutorix/features/dashboard/presentation/pages/profile_page.dart';
import 'package:tutorix/features/dashboard/presentation/pages/search_page.dart';



class BottomScreenLayout extends StatefulWidget {
  const BottomScreenLayout({super.key});

  @override
  State<BottomScreenLayout> createState() => _BottomScreenLayoutState();
}

class _BottomScreenLayoutState extends State<BottomScreenLayout> {
  int _selectedIndex = 0;

  /// List of screens for bottom nav
  final List<Widget> _screens = const [
    HomePage(),
    SearchPage(),
    BookingPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        backgroundColor: Colors.blueGrey,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
