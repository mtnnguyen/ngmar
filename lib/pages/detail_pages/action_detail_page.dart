import 'package:flutter/material.dart';

const darkBackground = Color(0xFF121212);

// The main page to display action details
class ActionDetailPage extends StatelessWidget {
  const ActionDetailPage({super.key});

  // Displays the details of a specific action
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(title: const Text('Action Detail')),
      body: const Center(child: Text('Details about a specific action.')),
    );
  }
}
