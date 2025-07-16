import 'package:flutter/material.dart'; // For material design components
import 'pages/alerts_page.dart'; // For alerts page
import 'pages/actions_page.dart'; // For actions page
import 'pages/events_page.dart'; // For events page
import 'widgets/bottom_nav_bar.dart'; // For bottom navigation bar

const darkBackground = Color(0xFF121212); // Dark background color for the app

// Main entry point of the application
void main() => runApp(const InboxApp());

/// The main application widget
class InboxApp extends StatelessWidget {
  const InboxApp({super.key});

  // Builds the main application
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

// Displaying different pages
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  
  @override
  State<HomePage> createState() => _HomePageState();
}

// State for the HomePage widget
class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    AlertsPage(),
    ActionsPage(),
    EventsPage(),
  ];

  // Handles bottom navigation bar item taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Builds the HomePage with a bottom navigation bar
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
