import 'package:flutter/material.dart';
import 'pharmacy_scene_painter.dart';
import 'graphql_service.dart';
import 'product_status_page.dart';

const darkBackground = Color(0xFF121212);

// image root that matches your tree in the screenshot
const _assetRoot = 'lib/images';

const productMetadata = {
  'IND_SUR': {'name': 'Indoor Surveillance', 'icon': Icons.sensor_door},
  'OUT_SUR': {'name': 'Outdoor Surveillance', 'icon': Icons.videocam_outlined},
  'TIM_TRA': {'name': 'Employee Time Tracking', 'icon': Icons.access_time},
  'PHA_GOV': {'name': 'Pharmacy Governance', 'icon': Icons.local_pharmacy},
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

class _MyProductsPageState extends State<MyProductsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Map<String, dynamic>> availableSections = [];

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();
    fetchProducts();
  }

  // --- helpers to mirror ProductStatusPage ---

  // 0/1/2 -> 'green' / 'yellow' / 'red' (filenames)
  String _colorFor(int? flag) {
    switch (flag) {
      case 1:
        return 'yellow';
      case 2:
        return 'red';
      case 0:
      default:
        return 'green';
    }
  }

  // ProductCode -> short suffix used in your filenames
  String _shortFor(String code) {
    const map = {
      'IND_SUR': 'ind',
      'OUT_SUR': 'out',
      'PHA_GOV': 'phar',
      'TIM_TRA': 'tim',
    };
    return map[code] ?? code.toLowerCase();
  }

  // Build the asset path we would show on the status page
  String _assetFor(String productCode, int? flag) {
    final color = _colorFor(flag);
    final short = _shortFor(productCode);
    return '$_assetRoot/products/$productCode/${color}_$short.png';
    // e.g. lib/images/products/IND_SUR/green_ind.png
  }

  // Derive the dot color from the actual filename prefix
  Color _dotColorFromAssetPath(String assetPath) {
    final file = assetPath.split('/').last.toLowerCase();
    final prefix = file.split('_').first; // green / yellow / red
    switch (prefix) {
      case 'green':
        return Colors.green;
      case 'yellow':
      case 'amber':
        return Colors.orange;
      case 'red':
        return Colors.red;
      default:
        return Colors.white70;
    }
  }

  Future<void> fetchProducts() async {
    setState(() {
      _loading = true;
      _error = null;
      availableSections.clear();
    });

    final graphqlService = GraphQLService();

    try {
      final licensedCodes =
          await graphqlService.getProductLicenses(widget.siteName, widget.partyId);

      if (!mounted) return;

      if (licensedCodes.isEmpty) {
        throw Exception('No product licenses found.');
      }

      // keep only known codes
      final codes =
          licensedCodes.where((c) => productMetadata.containsKey(c)).toList();

      // fetch each product's status in parallel
      final results = await Future.wait(codes.map((code) async {
        final status = await graphqlService.getProductStatus(
          siteName: widget.siteName,
          partyId: widget.partyId,
          productCode: code,
        );
        return {'code': code, 'status': status};
      }));

      if (!mounted) return;

      final sections = <Map<String, dynamic>>[];
      for (final r in results) {
        final code = r['code'] as String;
        final status = r['status'] as Map<String, dynamic>?; // null => skip
        if (status == null) continue;

        final meta = productMetadata[code]!;
        final rawFlag = status['product_status_flag'];
        final flag = rawFlag is int ? rawFlag : int.tryParse('$rawFlag') ?? 0;

        sections.add({
          'title': meta['name'],
          'icon': meta['icon'],
          'code': code,
          'flag': flag, // keep for building image path
        });
      }

      setState(() {
        availableSections = sections;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
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
        builder: (context, _) =>
            CustomPaint(painter: PharmacyScenePainter(animationValue: _controller.value)),
      ),
    );
  }

  Widget _buildSectionTile(String title, IconData icon, String code, {int? flag}) {
    final assetPath = _assetFor(code, flag);
    final dotColor = _dotColorFromAssetPath(assetPath);

    return Card(
      color: Colors.grey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        leading: Icon(icon, color: Colors.lightBlueAccent, size: 32),
        title: Text(title, style: const TextStyle(fontSize: 18, color: Colors.white)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dot color derived from the SAME image name used on the status page
            Icon(Icons.circle, color: dotColor, size: 12),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 18),
          ],
        ),
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
            else if (availableSections.isEmpty)
              const Center(
                child: Text('No products available.',
                    style: TextStyle(color: Colors.white70)),
              )
            else
              ...availableSections.map((s) => _buildSectionTile(
                    s['title'] as String,
                    s['icon'] as IconData,
                    s['code'] as String,
                    flag: s['flag'] as int?,
                  )),
          ],
        ),
      ),
    );
  }
}
