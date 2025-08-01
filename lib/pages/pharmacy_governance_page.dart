import 'package:flutter/material.dart';

class PharmacyGovernancePage extends StatelessWidget {
  const PharmacyGovernancePage({super.key});

  // Mocked status (replace with API integration later)
  final bool pharmacistAtCounter = true;
  final bool unauthorizedPersonnelDetected = false;

  @override
  Widget build(BuildContext context) {
    final bool alert = !pharmacistAtCounter || unauthorizedPersonnelDetected;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pharmacy Governance'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFF121212),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPharmacyImage(alert),
          const SizedBox(height: 24),
          _buildStatusRow('Pharmacist at Counter', pharmacistAtCounter),
          const SizedBox(height: 12),
          _buildStatusRow('Unauthorized Personnel', !unauthorizedPersonnelDetected),
          const SizedBox(height: 24),
          const Text(
            'This view monitors activity at the pharmacy counter and restricted zones.',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 24),
          const Text(
            'API integration coming soon...',
            style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildPharmacyImage(bool alert) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(
          color: alert ? Colors.red : Colors.green,
          width: 5,
        ),
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: AssetImage('assets/pharmacy_scene.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, bool ok) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle : Icons.warning,
            color: ok ? Colors.greenAccent : Colors.redAccent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Text(
            ok ? 'OK' : 'Alert',
            style: TextStyle(
              color: ok ? Colors.greenAccent : Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
