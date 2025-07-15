import 'package:flutter/material.dart';
import 'pages/alerts_page.dart';
import 'pages/actions_page.dart';
import 'pages/events_page.dart';
import 'widgets/bottom_nav_bar.dart';

const darkBackground = Color(0xFF121212);

void main() => runApp(const InboxApp());

class InboxApp extends StatelessWidget {
  const InboxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    AlertsPage(),
    ActionsPage(),
    EventsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
