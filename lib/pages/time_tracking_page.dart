import 'package:flutter/material.dart';

class TimeTrackingPage extends StatelessWidget {
  const TimeTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Time Tracking')),
      body: const Center(
        child: Text(
          'Employee time tracking view goes here.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
