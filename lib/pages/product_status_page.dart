import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'graphql_service.dart';
import 'navbar_widget.dart';
import 'alerts_page.dart';
import 'menu_page.dart';

const darkBackground = Color(0xFF121212);
const _assetRoot = 'assets/images';

const _productMap = {
  'IND_SUR': 'Indoor Surveillance',
  'OUT_SUR': 'Outdoor Surveillance',
  'TIM_TRA': 'Employee Time Tracking',
  'PHA_GOV': 'Pharmacy Governance',
};

class ProductStatusPage extends StatefulWidget {
  final String productCode;
  final String siteName;
  final int partyId;
  final String username;
  final String password;
  final String fullName;
  final String email;

  const ProductStatusPage({
    super.key,
    required this.productCode,
    required this.siteName,
    required this.partyId,
    required this.username,
    required this.password,
    required this.fullName,
    required this.email,
  });

  @override
  State<ProductStatusPage> createState() => _ProductStatusPageState();
}

class _ProductStatusPageState extends State<ProductStatusPage>
    with SingleTickerProviderStateMixin {
  late String _selectedCode;
  List<String> _availableCodes = [];
  bool _loading = true;
  String? _error;
  int? _productStatusFlag;
  List<Map<String, dynamic>> _statuses = [];
  bool _showProductList = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _selectedCode = widget.productCode;
    _fadeController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fetchAvailableProducts();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _fetchAvailableProducts() async {
    try {
      final svc = GraphQLService();
      final codes =
          await svc.getProducts(siteName: widget.siteName, partyId: widget.partyId);

      setState(() {
        _availableCodes = (codes ?? []).cast<String>();
      });

      await _fetchStatus();
    } catch (_) {
      setState(() {
        _availableCodes = [widget.productCode];
        _error = 'Failed to load product list.';
      });
    }
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
        productCode: _selectedCode,
      );

      if (resp == null) {
        setState(() {
          _error = 'Unable to load product status.';
          _loading = false;
        });
        return;
      }

      final rawFlag = resp['product_status_flag'];
      final resolvedFlag = rawFlag is int ? rawFlag : (int.tryParse('$rawFlag') ?? 0);

      final statuses = (resp['statuses'] as List?)
              ?.map((e) => (e as Map).map((k, v) => MapEntry(k.toString(), v)))
              .cast<Map<String, dynamic>>()
              .toList() ??
          <Map<String, dynamic>>[];

      setState(() {
        _productStatusFlag = _statuses.any((s) => s['product_status_flag'] == 2)
          ? 2
          : _statuses.any((s) => s['product_status_flag'] == 1)
              ? 1
              : 0;

              _statuses = statuses;
              _loading = false;
            });
      // Warm the asset (and try amber if yellow missing).
      try {
        await rootBundle.load(_assetFor(_selectedCode, resolvedFlag));
      } catch (_) {
        try {
          await rootBundle
              .load(_assetFor(_selectedCode, resolvedFlag).replaceFirst('/yellow_', '/amber_'));
        } catch (_) {}
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load product status.';
        _loading = false;
      });
    }
  }

  String _colorFor(int? flag) {
    switch (flag) {
      case 1:
        return 'yellow';
      case 2:
        return 'red';
      default:
        return 'green';
    }
  }

  String _shortFor(String code) {
    const map = {'IND_SUR': 'ind', 'OUT_SUR': 'out', 'PHA_GOV': 'phar', 'TIM_TRA': 'tim'};
    return map[code] ?? code.toLowerCase();
  }

  String _assetFor(String code, int? flag) {
    final color = _colorFor(flag);
    final short = _shortFor(code);
    return '$_assetRoot/products/$code/${color}_$short.png';
  }

  Color _colorFromFlag(int? flag) {
    switch (flag) {
      case 1:
        return Colors.orange;
      case 2:
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final assetPath = _assetFor(_selectedCode, _productStatusFlag);
    final altPath = assetPath.replaceFirst('/yellow_', '/amber_');

    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        backgroundColor: darkBackground,
        centerTitle: true,
        title: Text(
          _productMap[_selectedCode] ?? _selectedCode,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          TopRightNavBar(
            onAlertsTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => AlertsPage(
                    partyId: widget.partyId,
                    username: widget.username,
                    password: widget.password,
                    siteName: widget.siteName,
                    fullName: widget.fullName,
                    email: widget.email,
                  ),
                ),
              );
            },
            onPushTap: () => debugPrint('Push notification tapped'),
            onMenuTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => MenuPage(
                    partyId: widget.partyId,
                    username: widget.username,
                    password: widget.password,
                    siteName: widget.siteName,
                    fullName: widget.fullName,
                    email: widget.email,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchStatus,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Product picker (expand/collapse)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showProductList = !_showProductList;
                        if (_showProductList) {
                          _fadeController.forward();
                        } else {
                          _fadeController.reverse();
                        }
                      });
                    },
                    child: Row(
                      children: [
                        const Text(
                          'Product',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _showProductList ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  SizeTransition(
                    sizeFactor: _fadeAnimation,
                    axisAlignment: -1.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _availableCodes
                          .where((code) => code != _selectedCode)
                          .map(
                            (code) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                _productMap[code] ?? code,
                                style: const TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedCode = code;
                                  _showProductList = false;
                                });
                                _fadeController.reverse();
                                _fetchStatus();
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Status image
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Center(
                key: ValueKey(assetPath),
                child: SizedBox(
                  height: 140,
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Image.asset(
                      altPath,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) =>
                          Icon(Icons.circle, size: 120, color: _colorFromFlag(_productStatusFlag)),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Status list
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
                child: Text('No statuses available.',
                    style: TextStyle(color: Colors.white70)),
              )
            else
              ..._statuses.map((item) {
                final name = item['product_status_name']?.toString() ?? 'Unknown';
                final value = item['product_status_value']?.toString() ?? '';
                final flag = item['product_status_flag'] as int? ?? 0;
                final dotColor = _colorFromFlag(flag);
                return Card(
                  color: Colors.grey.shade900,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '$name : $value',
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                        Icon(Icons.circle, size: 14, color: dotColor),
                      ],
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
