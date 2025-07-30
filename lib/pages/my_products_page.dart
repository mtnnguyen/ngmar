import 'package:flutter/material.dart';
import 'pharmacy_scene_painter.dart';

const darkBackground = Color(0xFF121212);

class MyProductsPage extends StatefulWidget {
  const MyProductsPage({super.key});

  @override
  State<MyProductsPage> createState() => _MyProductsPageState();
}

class _MyProductsPageState extends State<MyProductsPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final products = [
    {
      'name': 'AI Camera – Front Gate',
      'type': 'Camera',
      'status': 'Online',
      'lastActive': DateTime.now().subtract(const Duration(minutes: 6)),
      'pharmacistAtCounter': false,
      'compliance': true,
      'indoor': false,
      'trackedByRcon': true,
      'icon': Icons.videocam,
    },
    {
      'name': 'Access Control Panel',
      'type': 'Access',
      'status': 'Offline',
      'lastActive': DateTime.now().subtract(const Duration(minutes: 240)),
      'pharmacistAtCounter': true,
      'compliance': false,
      'indoor': true,
      'trackedByRcon': true,
      'icon': Icons.vpn_key,
    },
    {
      'name': 'Intrusion Sensor – Lobby',
      'type': 'Sensor',
      'status': 'Online',
      'lastActive': DateTime.now().subtract(const Duration(minutes: 32)),
      'pharmacistAtCounter': true,
      'compliance': true,
      'indoor': true,
      'trackedByRcon': false,
      'icon': Icons.sensors,
    },
  ];

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

  Widget _buildProductCard(Map<String, dynamic> p) {
    final isOnline = p['status'] == 'Online';
    final isCompliant = p['compliance'] == true;
    final pharmacistHere = p['pharmacistAtCounter'] == true;
    final indoor = p['indoor'] == true;
    final lastActive = p['lastActive'] as DateTime;
    final minutesAgo = DateTime.now().difference(lastActive).inMinutes;

    return Card(
      color: Colors.grey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(p['icon'] as IconData, color: Colors.blueAccent, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(p['name'], style: const TextStyle(color: Colors.white, fontSize: 18)),
                ),
                const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
              ],
            ),
            const SizedBox(height: 8),
            Text('${p['type']} • Status: ${p['status']}',
                style: TextStyle(color: isOnline ? Colors.green : Colors.red)),
            const SizedBox(height: 4),
            Text('Last activity: $minutesAgo mins ago',
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 4),
            Text('Compliance: ${isCompliant ? 'In Compliance' : 'Not in Compliance'}',
                style: TextStyle(color: isCompliant ? Colors.greenAccent : Colors.orangeAccent)),
            const SizedBox(height: 4),
            Text('Pharmacist: ${pharmacistHere ? 'At Counter' : 'Not at Counter'}',
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 4),
            Text('Location: ${indoor ? 'Indoor' : 'Outdoor'}',
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 4),
            if (p['trackedByRcon'] == true)
              const Text('Tracked by RCON', style: TextStyle(color: Colors.cyanAccent)),
          ],
        ),
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/pharmacy_logo.png', height: 28), // Add this asset
            const SizedBox(width: 8),
            const Text('My Products'),
          ],
        ),
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
