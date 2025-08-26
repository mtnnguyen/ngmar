import 'package:flutter/material.dart';
import 'pharmacy_scene_painter.dart';
import 'graphql_service.dart';
import 'product_status_page.dart';

const darkBackground = Color(0xFF121212);

const productMetadata = {
  'IND_SUR': {
    'name': 'Indoor Surveillance',
    'icon': Icons.sensor_door,
  },
  'OUT_SUR': {
    'name': 'Outdoor Surveillance',
    'icon': Icons.videocam_outlined,
  },
  'TIM_TRA': {
    'name': 'Employee Time Tracking',
    'icon': Icons.access_time,
  },
  'PHA_GOV': {
    'name': 'Pharmacy Governance',
    'icon': Icons.local_pharmacy,
  },
};

class MyProductsPage extends StatefulWidget {
  final String username;
  final String password;
  final String siteName;
  final int partyId;

  const MyProductsPage({
    super.key,
    required this.username,
    required this.password,
    required this.siteName,
    required this.partyId,
  });

  @override
  State<MyProductsPage> createState() => _MyProductsPageState();
}

class _MyProductsPageState extends State<MyProductsPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Map<String, dynamic>> availableSections = [];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() {
      _loading = true;
      _error = null;
      availableSections.clear();
    });

    final graphqlService = GraphQLService();

    print('fetchProducts START for user=${widget.username}, partyId=${widget.partyId}, site=${widget.siteName}');

    try {
      final licensedCodes = await graphqlService.getProductLicenses(
        widget.siteName,
        widget.partyId,
      );

      print('Licensed product codes: $licensedCodes');

      if (licensedCodes.isEmpty) {
        throw Exception("No product licenses found.");
      }

      for (final code in licensedCodes) {
        if (!productMetadata.containsKey(code)) {
          print('Unknown product code skipped: $code');
          continue;
        }

        print('Fetching status for $code...');

        final status = await graphqlService.getProductStatus(
          siteName: widget.siteName,
          partyId: widget.partyId,
          productCode: code,
        );

        print('Status response for $code: $status');

        if (status != null) {
          availableSections.add({
            'title': productMetadata[code]!['name'],
            'icon': productMetadata[code]!['icon'],
            'code': code,
          });
        }
      }

      setState(() {
        _loading = false;
      });

      print('Final availableSections: $availableSections');
    } catch (e) {
      print('Error in fetchProducts: $e');
      setState(() {
        _loading = false;
        _error = 'Failed to load products. Please try again later.';
      });
    }
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

  Widget _buildSectionTile(String title, IconData icon, String code) {
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
        onTap: () async {
          print('Navigating to status page for $code ($title)');
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductStatusPage(
                siteName: widget.siteName,
                partyId: widget.partyId,
                productCode: code,
                productTitle: title,
              ),
            ),
          );
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
      body: RefreshIndicator(
        onRefresh: fetchProducts,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildAnimatedHeader(),
            const SizedBox(height: 16),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Center(
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                ),
              )
            else
              ...availableSections.map((section) => _buildSectionTile(
                    section['title'],
                    section['icon'],
                    section['code'],
                  )),
          ],
        ),
      ),
    );
  }
}
