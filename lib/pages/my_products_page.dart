import 'package:flutter/material.dart';
import 'pharmacy_scene_painter.dart';
import 'pharmacy_governance_page.dart';
import 'time_tracking_page.dart';
import 'indoor_surveillance_page.dart';
import 'outdoor_surveillance_page.dart';

const darkBackground = Color(0xFF121212);

class MyProductsPage extends StatefulWidget {
  const MyProductsPage({super.key});

  @override
  State<MyProductsPage> createState() => _MyProductsPageState();
}

class _MyProductsPageState extends State<MyProductsPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<Map<String, dynamic>> sections = [
    {
      'title': 'Pharmacy Governance',
      'icon': Icons.local_pharmacy,
    },
    {
      'title': 'Time Tracking',
      'icon': Icons.access_time,
    },
    {
      'title': 'Indoor Surveillance',
      'icon': Icons.sensor_door,
    },
    {
      'title': 'Outdoor Surveillance',
      'icon': Icons.videocam_outlined,
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

  Widget _buildSectionTile(String title, IconData icon) {
    return Card(
      color: Colors.grey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Icon(icon, color: Colors.lightBlueAccent, size: 32),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 18),
        onTap: () {
          // TODO: Navigate or handle tap
          onTap: () {
            switch (title) {
              case 'Pharmacy Governance':
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PharmacyGovernancePage()));
                break;
              case 'Time Tracking':
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const TimeTrackingPage()));
                break;
              case 'Indoor Surveillance':
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const IndoorSurveillancePage()));
                break;
              case 'Outdoor Surveillance':
                Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const OutdoorSurveillancePage()));
                break;
            }
          };
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/pharmacy_logo.png', height: 28),
            const SizedBox(width: 8),
            const Text('Pharmacy Governance'),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAnimatedHeader(),
          const SizedBox(height: 16),
          ...sections.map((section) => _buildSectionTile(section['title'], section['icon'])),
        ],
      ),
    );
  }
}
