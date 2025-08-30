// File: product_status_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'graphql_service.dart';
import 'navbar_widget.dart';
import 'alerts_page.dart';
import 'menu_page.dart';
import 'push_notifications_page.dart';

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

class _ProductStatusPageState extends State<ProductStatusPage> with SingleTickerProviderStateMixin {
  late final GraphQLService _service;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  late String _selectedCode;
  List<String> _availableCodes = [];
  List<Map<String, dynamic>> _statuses = [];
  int? _productStatusFlag;
  String? _error;
  bool _loading = true;
  bool _showProductList = false;

  @override
  void initState() {
    super.initState();
    _selectedCode = widget.productCode;
    _service = GraphQLService();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fetchAvailableProducts();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  int _asInt(dynamic v, [int fallback = 0]) => v is int ? v : int.tryParse(v.toString()) ?? fallback;

  String _shortFor(String code) => {
    'IND_SUR': 'ind',
    'OUT_SUR': 'out',
    'PHA_GOV': 'phar',
    'TIM_TRA': 'tim',
  }[code] ?? code.toLowerCase();

  Color _dotColorFromFlag(int? flag) => flag == 2 ? Colors.red : flag == 1 ? Colors.amber : Colors.green;

  String _getStatusColor(List<Map<String, dynamic>> statuses) {
    bool hasRed = false;
    bool hasYellow = false;

    for (var status in statuses) {
      final flag = _asInt(status['product_status_flag']);
      if (flag == 2) return 'red';
      if (flag == 1) hasYellow = true;
    }

    if (hasYellow) return 'yellow';
    return 'green';
  }

  String _assetFor(String code, String color) {
    final short = _shortFor(code);
    return '$_assetRoot/products/$code/${color}_$short.png';
  }

  List<Map<String, dynamic>> _extractStatuses(dynamic resp) {
    if (resp is Map && resp['statuses'] is List) {
      return List<Map<String, dynamic>>.from(
        (resp['statuses'] as List).whereType<Map>().map((e) => e.map((k, v) => MapEntry(k.toString(), v))),
      );
    } else if (resp is List) {
      return List<Map<String, dynamic>>.from(
        resp.whereType<Map>().map((e) => e.map((k, v) => MapEntry(k.toString(), v))),
      );
    }
    return [];
  }

  Future<void> _fetchAvailableProducts() async {
    try {
      final codes = await _service.getProducts(siteName: widget.siteName, partyId: widget.partyId);
      _availableCodes = (codes ?? []).cast<String>();
    } catch (_) {
      _availableCodes = [widget.productCode];
      _error = 'Failed to load product list.';
    }
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    setState(() {
      _loading = true;
      _error = null;
      _statuses.clear();
      _productStatusFlag = null;
    });

    try {
      final rawResp = await _service.getProductStatus(
        siteName: widget.siteName,
        partyId: widget.partyId,
        productCode: _selectedCode,
      );

      final statuses = _extractStatuses(rawResp);
      final statusColor = _getStatusColor(statuses);

      setState(() {
        _statuses = statuses;
        _productStatusFlag = statusColor == 'red' ? 2 : statusColor == 'yellow' ? 1 : 0;
        _loading = false;
      });

      try {
        await rootBundle.load(_assetFor(_selectedCode, statusColor));
      } catch (_) {
        try {
          await rootBundle.load(
            _assetFor(_selectedCode, statusColor).replaceFirst('/yellow_', '/amber_'),
          );
        } catch (_) {}
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load product status.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(_statuses);
    final assetPath = _assetFor(_selectedCode, statusColor);
    final altPath = assetPath.replaceFirst('/yellow_', '/amber_');

    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        backgroundColor: darkBackground,
        title: const SizedBox.shrink(),
        actions: [
          TopRightNavBar(
            onAlertsTap: () => Navigator.pushReplacement(
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
            ),
            onMenuTap: () => Navigator.pushReplacement(
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
            ),
            onPushTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PushNotificationsPage(
                  partyId: widget.partyId,
                  username: widget.username,
                  password: widget.password,
                  siteName: widget.siteName,
                  fullName: widget.fullName,
                  email: widget.email,
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchStatus,
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () {
                  setState(() => _showProductList = !_showProductList);
                  _showProductList ? _fadeController.forward() : _fadeController.reverse();
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _productMap[_selectedCode] ?? _selectedCode,
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      _showProductList ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            SizeTransition(
              sizeFactor: _fadeAnimation,
              axisAlignment: -1.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _availableCodes
                    .where((code) => code != _selectedCode)
                    .map((code) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(_productMap[code] ?? code, style: const TextStyle(color: Colors.white)),
                          onTap: () {
                            setState(() {
                              _selectedCode = code;
                              _showProductList = false;
                            });
                            _fadeController.reverse();
                            _fetchStatus();
                          },
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 12),
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
                      errorBuilder: (_, __, ___) => Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: _dotColorFromFlag(_productStatusFlag),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_loading)
              const Center(child: Padding(padding: EdgeInsets.only(top: 24), child: CircularProgressIndicator()))
            else if (_error != null)
              Column(
                children: [
                  Text(_error!, style: const TextStyle(color: Colors.redAccent), textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  OutlinedButton(onPressed: _fetchStatus, child: const Text('Retry')),
                ],
              )
            else if (_statuses.isEmpty)
              const Center(child: Text('No statuses available.', style: TextStyle(color: Colors.white70)))
            else
              ..._statuses.map((item) {
                final name = item['product_status_name']?.toString() ?? 'Unknown';
                final value = item['product_status_value']?.toString() ?? '';
                final flag = _asInt(item['product_status_flag']);
                final dotColor = _dotColorFromFlag(flag);
                return Card(
                  color: Colors.grey.shade900,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text('$name : $value', style: const TextStyle(color: Colors.white, fontSize: 16))),
                        Container(width: 14, height: 14, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
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
