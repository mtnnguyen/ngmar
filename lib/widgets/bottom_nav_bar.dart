import 'package:flutter/material.dart';

// The bottom navigation bar with different pages
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  const BottomNavBar({super.key, required this.currentIndex, this.onTap});

  // The three icons added to the bottom navigation bar (alerts, actions, events)
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
      backgroundColor: Colors.black,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
        BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: 'Actions'),
        BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
      ],
      onTap: onTap,
    );
  }
}
