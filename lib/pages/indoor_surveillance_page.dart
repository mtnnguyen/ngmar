import 'package:flutter/material.dart';

class IndoorSurveillancePage extends StatelessWidget {
  const IndoorSurveillancePage({super.key});

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
