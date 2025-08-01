import 'package:flutter/material.dart';

class OutdoorSurveillancePage extends StatelessWidget {
  const OutdoorSurveillancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Outdoor Surveillance')),
      body: const Center(
        child: Text(
          'Outdoor surveillance feed or data view goes here.',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
