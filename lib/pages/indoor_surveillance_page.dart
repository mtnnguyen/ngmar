import 'package:flutter/material.dart';

/// A page that displays indoor surveillance information.
class IndoorSurveillancePage extends StatelessWidget {
  const IndoorSurveillancePage({super.key});

  /// The route name for this page.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Indoor Surveillance')),
      body: const Center(
        child: Text(
          'Indoor surveillance feed or data view goes here.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
