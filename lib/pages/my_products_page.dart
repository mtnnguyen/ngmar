import 'package:flutter/material.dart';

const darkBackground = Color(0xFF121212);

class MyProductsPage extends StatelessWidget {
  const MyProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final products = [
      {
        'name': 'AI Camera – Front Gate',
        'type': 'Camera',
        'status': 'Online',
        'lastActive': '2025‑07‑23',
        'icon': Icons.videocam,
      },
      {
        'name': 'Access Control Panel',
        'type': 'Access',
        'status': 'Offline',
        'lastActive': '2025‑07‑20',
        'icon': Icons.vpn_key,
      },
      {
        'name': 'Intrusion Sensor – Lobby',
        'type': 'Sensor',
        'status': 'Online',
        'lastActive': '2025‑07‑25',
        'icon': Icons.sensors,
      },
    ];

    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        backgroundColor: darkBackground,
        centerTitle: true,
        title: const Text('My Products'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final p = products[index];
          final isOnline = p['status'] == 'Online';
          return Card(
            color: Colors.grey.shade900,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: Icon(p['icon'] as IconData, color: Colors.blueAccent, size: 32),
              title: Text(p['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 18)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${p['type']} • Status: ${p['status']}', style: TextStyle(color: isOnline ? Colors.green : Colors.red)),
                  const SizedBox(height: 4),
                  Text('Last active: ${p['lastActive']}', style: const TextStyle(color: Colors.white70)),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38),
              onTap: () {
                // TODO: Navigate to product detail page
              },
            ),
          );
        },
      ),
    );
  }
}
