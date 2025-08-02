import 'package:flutter/material.dart';

// TimeTrackingPage is a page for employee time tracking
class TimeTrackingPage extends StatelessWidget {
  const TimeTrackingPage({super.key});

  // This widget is the root of the TimeTrackingPage.
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
