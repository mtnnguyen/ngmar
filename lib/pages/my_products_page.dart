import 'package:flutter/material.dart';
import 'pharmacy_scene_painter.dart'; // Uses external drawing file

const darkBackground = Color(0xFF121212);

class MyProductsPage extends StatefulWidget {
  const MyProductsPage({super.key});

  @override
  State<MyProductsPage> createState() => _MyProductsPageState();
}

// Lists products with an animated header.
class _MyProductsPageState extends State<MyProductsPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

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

  // Animation controller for the animated header
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Builds the animated header with the pharmacy scene
  Widget _buildAnimatedHeader() {
    return SizedBox(
      height: 240,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: PharmacyScenePainter(animationValue: _controller.value),
          );
        },
      ),
    );
  }

  // Builds each product card with details
  Widget _buildProductCard(Map<String, dynamic> p) {
    final isOnline = p['status'] == 'Online';
    return Card(
      color: Colors.grey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(p['icon'] as IconData, color: Colors.blueAccent, size: 32),
        title: Text(p['name'] as String, style: const TextStyle(color: Colors.white, fontSize: 18)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${p['type']} • Status: ${p['status']}',
                style: TextStyle(color: isOnline ? Colors.green : Colors.red)),
            const SizedBox(height: 4),
            Text('Last active: ${p['lastActive']}',
                style: const TextStyle(color: Colors.white70)),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38),
        onTap: () {
          // TODO: Navigate to detail page
        },
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        backgroundColor: darkBackground,
        centerTitle: true,
        title: const Text('My Products'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAnimatedHeader(),
          const SizedBox(height: 16),
          ...products.map(_buildProductCard),
        ],
      ),
    );
  }
}
