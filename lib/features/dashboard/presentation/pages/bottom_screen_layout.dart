import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:tutorix/features/dashboard/presentation/pages/booking_page.dart';
import 'package:tutorix/features/dashboard/presentation/pages/categories_page.dart';
import 'package:tutorix/features/dashboard/presentation/pages/home_page.dart';
import 'package:tutorix/features/dashboard/presentation/pages/profile_page.dart';
import 'package:tutorix/features/dashboard/presentation/pages/search_page.dart';



class BottomScreenLayout extends StatefulWidget {
  const BottomScreenLayout({
    super.key,
    this.initialIndex = 0,
  });

  final int initialIndex;

  @override
  State<BottomScreenLayout> createState() => _BottomScreenLayoutState();
}

class _BottomScreenLayoutState extends State<BottomScreenLayout> {
  late int _selectedIndex;
  StreamSubscription<AccelerometerEvent>? _tiltSubscription;
  DateTime? _lastTiltSwitchAt;

  static const double _tiltThreshold = 6.5;
  static const Duration _tiltCooldown = Duration(milliseconds: 900);

  /// List of screens for bottom nav
  final List<Widget> _screens = const [
    HomePage(),
    SearchPage(),
    CategoriesPage(),
    BookingPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex.clamp(0, 4);
    _tiltSubscription = accelerometerEventStream().listen((event) {
      if (!mounted) return;

      final now = DateTime.now();
      final last = _lastTiltSwitchAt;
      if (last != null && now.difference(last) < _tiltCooldown) {
        return;
      }

      if (event.x >= _tiltThreshold && _selectedIndex > 0) {
        setState(() {
          _selectedIndex -= 1;
          _lastTiltSwitchAt = now;
        });
      } else if (event.x <= -_tiltThreshold && _selectedIndex < _screens.length - 1) {
        setState(() {
          _selectedIndex += 1;
          _lastTiltSwitchAt = now;
        });
      }
    });
  }

  @override
  void dispose() {
    _tiltSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
        }
        return false;
      },
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.blueGrey,
          selectedItemColor: Colors.white,
          unselectedItemColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.white70
              : Colors.black,
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
              icon: Icon(Icons.category),
              label: 'Categories',
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
      ),
    );
  }
}
