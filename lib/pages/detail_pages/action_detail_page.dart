import 'package:flutter/material.dart';

const darkBackground = Color(0xFF121212);

class ActionDetailPage extends StatelessWidget {
  const ActionDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(title: const Text('Action Detail')),
      body: const Center(child: Text('Details about a specific action.')),
    );
  }
}
