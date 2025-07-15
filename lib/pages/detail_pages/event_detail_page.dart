import 'package:flutter/material.dart';

const darkBackground = Color(0xFF121212);

class EventDetailPage extends StatelessWidget {
  const EventDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(title: const Text('Event Detail')),
      body: const Center(child: Text('Details about a specific event.')),
    );
  }
}
