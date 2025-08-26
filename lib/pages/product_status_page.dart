import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle; // for optional existence check
import 'graphql_service.dart';

const darkBackground = Color(0xFF121212);

// Matches your folder tree: lib/images/products/...
const _assetRoot = 'assets/images';

class ProductStatusPage extends StatefulWidget {
  final String productCode;   // e.g., IND_SUR, OUT_SUR, TIM_TRA, PHA_GOV
  final String productTitle;  // e.g., Indoor Surveillance
  final String siteName;
  final int partyId;

  const ProductStatusPage({
    super.key,
    required this.productCode,
    required this.productTitle,
    required this.siteName,
    required this.partyId,
  });

  @override
  State<ProductStatusPage> createState() => _ProductStatusPageState();
}

class _ProductStatusPageState extends State<ProductStatusPage> {
  bool _loading = true;
  String? _error;

  // Response
  int? _productStatusFlag; // 0 green, 1 yellow, 2 red
  List<Map<String, dynamic>> _statuses = [];

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    setState(() {
      _loading = true;
      _error = null;
      _statuses = [];
      _productStatusFlag = null;
    });

    try {
      final svc = GraphQLService();
      final resp = await svc.getProductStatus(
        siteName: widget.siteName,
        partyId: widget.partyId,
        productCode: widget.productCode,
      );

      if (resp == null) {
        setState(() {
          _error = 'Unable to load product status.';
          _loading = false;
        });
        return;
      }

      final rawFlag = resp['product_status_flag'];
      final resolvedFlag = rawFlag is int ? rawFlag : int.tryParse('${rawFlag}');

      final statuses = (resp['statuses'] as List?)
              ?.cast<Map>()
              .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
              .toList() ??
          <Map<String, dynamic>>[];

      setState(() {
        _productStatusFlag = resolvedFlag;
        _statuses = statuses.cast<Map<String, dynamic>>();
        _loading = false;
      });

      // Optional: prove the asset exists (helps when debugging)
      final testPath = _assetFor(widget.productCode, resolvedFlag);
      try {
        await rootBundle.load(testPath);
        debugPrint('[ProductStatusPage] Asset found: $testPath');
      } catch (e) {
        debugPrint('[ProductStatusPage] Asset NOT found: $testPath -> $e');
        final alt = testPath.replaceFirst('/yellow_', '/amber_');
        try {
          await rootBundle.load(alt);
          debugPrint('[ProductStatusPage] Alt asset found: $alt');
        } catch (e2) {
          debugPrint('[ProductStatusPage] Alt asset NOT found: $alt -> $e2');
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load product status. $e';
        _loading = false;
      });
    }
  }

  // Map 0/1/2 -> 'green' / 'yellow' / 'red' for your filenames
  String _colorFor(int? flag) {
    switch (flag) {
      case 1:
        return 'yellow'; // you named these yellow_*.png
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

  // Full asset path that matches your structure:
  // lib/images/products/IND_SUR/green_ind.png, yellow_out.png, etc.
  String _assetFor(String productCode, int? flag) {
    final color = _colorFor(flag);
    final short = _shortFor(productCode);
    return '$_assetRoot/products/$productCode/${color}_$short.png';
  }

  // Derive dot color/label from the image filename (keeps UI in sync with logo)
  (Color color, String label) _colorLabelFromAssetPath(String assetPath) {
    final file = assetPath.split('/').last.toLowerCase();
    final prefix = file.split('_').first; // green / yellow / red / amber / etc.
    switch (prefix) {
      case 'green':
        return (Colors.green, 'GREEN');
      case 'yellow':
      case 'amber':
        return (Colors.orange, 'YELLOW');
      case 'red':
        return (Colors.red, 'RED');
      default:
        return (Colors.white70, 'UNKNOWN');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build the asset path once, then use its prefix to color the dot/label
    final assetPath = _assetFor(widget.productCode, _productStatusFlag);
    final altAssetPath = assetPath.replaceFirst('/yellow_', '/amber_'); // optional alt
    final (dotColor, dotLabel) = _colorLabelFromAssetPath(assetPath);

    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        backgroundColor: darkBackground,
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.productTitle),
            Text(
              widget.productCode,
              style: const TextStyle(fontSize: 12, color: Colors.white60),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchStatus,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Product name heading (boss request)
            Text(
              widget.productTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Product-specific image based on flag (centered). Defaults to green if null.
            Center(
              child: SizedBox(
                height: 140,
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) {
                    // Try amber_* if yellow_* is missing
                    return Image.asset(
                      altAssetPath,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) {
                        // Fallback to a big colored dot
                        return Icon(Icons.circle, size: 120, color: dotColor);
                      },
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Dot + label derived from the image name
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.circle, size: 12, color: dotColor),
                const SizedBox(width: 8),
                Text(
                  dotLabel,
                  style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 24),

            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_error != null)
              Column(
                children: [
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(onPressed: _fetchStatus, child: const Text('Retry')),
                ],
              )
            else if (_statuses.isEmpty)
              const Center(
                child: Text(
                  'No statuses available.',
                  style: TextStyle(color: Colors.white70),
                ),
              )
            else
              ..._statuses.map((item) {
                final name = item['product_status_name']?.toString() ?? 'Unknown';
                final value = item['product_status_value']?.toString() ?? '';
                return Card(
                  color: Colors.grey.shade900,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    title: Text(
                      '$name : $value',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
