import 'package:flutter/material.dart';
import 'pharmacy_scene_painter.dart';
import 'graphql_service.dart';

const darkBackground = Color(0xFF121212);

/// MyProductsPage displays a list of product sections with an animated header.
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

  final Map<String, String> productCodeToName = {
    'IND_SUR': 'Indoor Surveillance',
    'OUT_SUR': 'Outdoor Surveillance',
    'TIM_TRA': 'Employee Time Tracking',
    'PHA_GOV': 'Pharmacy Governance',
  };

  final Map<String, IconData> sectionIcons = {
    'Indoor Surveillance': Icons.sensor_door,
    'Outdoor Surveillance': Icons.videocam_outlined,
    'Employee Time Tracking': Icons.access_time,
    'Pharmacy Governance': Icons.local_pharmacy,
  };

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
    });

    try {
      final graphqlService = GraphQLService();

      final productCodes = await graphqlService.getProductLicenses(
        widget.siteName,
        widget.partyId,
        username: widget.username,
        password: widget.password,
      );

      print('\u{1F50C} Product codes received: $productCodes');

      final matched = productCodes
          .map((code) => productCodeToName[code])
          .where((name) => name != null)
          .toSet()
          .map((name) => {
                'title': name,
                'icon': sectionIcons[name]!,
                'code': productCodeToName.entries.firstWhere((e) => e.value == name).key,
              })
          .toList();

      setState(() {
        availableSections = matched;
        _loading = false;
      });
    } catch (e) {
      print('\u274C Error fetching products: $e');
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
      body: ListView(
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
    );
  }
}

class ProductStatusPage extends StatefulWidget {
  final String siteName;
  final int partyId;
  final String productCode;
  final String productTitle;

  const ProductStatusPage({
    super.key,
    required this.siteName,
    required this.partyId,
    required this.productCode,
    required this.productTitle,
  });

  @override
  State<ProductStatusPage> createState() => _ProductStatusPageState();
}

class _ProductStatusPageState extends State<ProductStatusPage> {
  Map<String, String> statuses = {};
  int? flag;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    fetchStatus();
  }

  Future<void> fetchStatus() async {
    final service = GraphQLService();
    try {
      final result = await service.getProductStatus(
        siteName: widget.siteName,
        partyId: widget.partyId,
        productCode: widget.productCode,
      );
      if (result != null) {
        setState(() {
          flag = result['product_status_flag'] as int?;
          statuses = {
            for (var s in result['statuses'])
              s['product_status_name'].toString(): s['product_status_value'].toString(),
          };
          _loading = false;
        });
      }
    } catch (e) {
      print('[ProductStatus] $e');
      setState(() {
        _loading = false;
      });
    }
  }

  String getStatusImage() {
    switch (flag) {
      case 0:
        return 'lib/images/green.png';
      case 1:
        return 'lib/images/amber.png';
      case 2:
        return 'lib/images/red.png';
      default:
        return 'lib/images/unknown.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        title: Text(widget.productTitle),
        backgroundColor: darkBackground,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Image.asset(getStatusImage(), height: 100)),
                  const SizedBox(height: 24),
                  const Text(
                    'Status Information:',
                    style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ...statuses.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '${entry.key}: ${entry.value}',
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
