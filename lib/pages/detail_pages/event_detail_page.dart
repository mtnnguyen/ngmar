import 'package:flutter/material.dart';

const darkBackground = Color(0xFF121212);

// The main page to display event details
class EventDetailPage extends StatelessWidget {
  const EventDetailPage({super.key});

  // Displays the details of a specific event
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(title: const Text('Event Detail')),
      body: const Center(child: Text('Details about a specific event.')),
    );
  }
}
