import 'package:flutter/material.dart';
import 'graphql_service.dart';

const darkBackground = Color(0xFF121212);

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
  int? _productStatusFlag; // 0 green, 1 amber, 2 red
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

      final flag = resp['product_status_flag'];
      final statuses = (resp['statuses'] as List?)?.cast<Map<String, dynamic>>() ?? <Map<String, dynamic>>[];

      setState(() {
        _productStatusFlag = flag is int ? flag : int.tryParse(flag?.toString() ?? '');
        _statuses = statuses;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load product status. $e';
        _loading = false;
      });
    }
  }

  // Maps 0/1/2 -> color + label (GREEN/AMBER/RED)
  (Color color, String label) _flagToColorAndLabel(int? flag) {
    switch (flag) {
      case 0:
        return (Colors.green, 'GREEN');
      case 1:
        return (Colors.amber, 'AMBER');
      case 2:
        return (Colors.red, 'RED');
      default:
        return (Colors.grey, 'UNKNOWN');
    }
  }

  Widget _buildFlagHeader() {
    final (color, label) = _flagToColorAndLabel(_productStatusFlag);

    // If you later get image assets, replace the CircleAvatar with Image.asset(...)
    return Row(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor: color,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        backgroundColor: darkBackground,
        centerTitle: true,
        // Boss asked: heading based on product_code — we show a friendly title and code.
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.redAccent),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFlagHeader(),
                      const SizedBox(height: 16),
                      const Text(
                        'Statuses',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _statuses.isEmpty
                            ? const Center(
                                child: Text(
                                  'No statuses available.',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              )
                            : ListView.separated(
                                itemCount: _statuses.length,
                                separatorBuilder: (_, __) => const Divider(color: Colors.white12),
                                itemBuilder: (context, index) {
                                  final item = _statuses[index];
                                  final name = item['product_status_name']?.toString() ?? 'Unknown';
                                  final value = item['product_status_value']?.toString() ?? '';
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(
                                      '$name : $value',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
