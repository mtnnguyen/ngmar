import 'package:flutter/material.dart';
import 'account_page.dart';
import 'indoor_surveillance_page.dart';
import 'outdoor_surveillance_page.dart';
import 'employee_time_tracking_page.dart';
import 'pharmacy_governance_page.dart';
import 'graphql_service.dart';
import 'navbar_widget.dart';
import 'alerts_page.dart';
import 'push_notifications_page.dart';
import 'privacy_screen.dart';
import 'legal_screen.dart';
import 'acknowledgements_screen.dart';

class MenuPage extends StatefulWidget {
  final int partyId;
  final String username;
  final String password;
  final String siteName;
  final String fullName;
  final String email;

  const MenuPage({
    super.key,
    required this.partyId,
    required this.username,
    required this.password,
    required this.siteName,
    required this.fullName,
    required this.email,
  });

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final GraphQLService _service = GraphQLService();
  List<String> licensedProductCodes = [];
  Map<String, int> productFlags = {};
  bool isLoading = true;

  static const productMeta = {
    'IND_SUR': {
      'title': 'Indoor Surveillance',
      'prefix': 'ind',
      'builder': IndoorSurveillancePage.new,
    },
    'OUT_SUR': {
      'title': 'Outdoor Surveillance',
      'prefix': 'out',
      'builder': OutdoorSurveillancePage.new,
    },
    'TIM_TRA': {
      'title': 'Employee Time Tracking',
      'prefix': 'tim',
      'builder': EmployeeTimeTrackingPage.new,
    },
    'PHA_GOV': {
      'title': 'Pharmacy Governance',
      'prefix': 'phar',
      'builder': PharmacyGovernancePage.new,
    },
  };

  @override
  void initState() {
    super.initState();
    _loadLicensedProducts();
  }

  Future<void> _loadLicensedProducts() async {
    setState(() => isLoading = true);
    try {
      final products = await _service.getProducts(
        siteName: widget.siteName,
        partyId: widget.partyId,
      );
      if (!mounted) return;
      licensedProductCodes = products ?? [];

      // Fetch status for each product
      final flags = <String, int>{};
      for (final code in licensedProductCodes) {
        final status = await _service.getProductStatus(
          siteName: widget.siteName,
          partyId: widget.partyId,
          productCode: code,
        );
        if (status != null) {
          flags[code] = status['product_status_flag'] ?? 0;
        }
      }

      if (!mounted) return;
      setState(() => productFlags = flags);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load products: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text('Menu'),
        actions: [
          TopRightNavBar(
            onAlertsTap: () => _navigateTo(context, AlertsPage.new),
            onPushTap: () => _navigateTo(context, PushNotificationsPage.new),
            onMenuTap: () {},
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : RefreshIndicator(
              color: Colors.white,
              onRefresh: _loadLicensedProducts,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildAccountTile(),
                  const SizedBox(height: 24),
                  ExpansionTile(
                    collapsedIconColor: Colors.white70,
                    iconColor: Colors.white70,
                    leading: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                    title: const Text('My Products', style: TextStyle(color: Colors.white)),
                    children: _buildProductTiles(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(color: Colors.grey),
            const SizedBox(height: 8),
            const Text('App Version v1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            _FooterBar(
              onPrivacy: () => _navigateTo(context, PrivacyScreen.new),
              onLegal: () => _navigateTo(context, LegalScreen.new),
              onAcknowledgements: () => _navigateTo(context, AcknowledgementsScreen.new),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget Function({required int partyId, required String username, required String password, required String siteName, required String fullName, required String email}) builder) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => builder(
          partyId: widget.partyId,
          username: widget.username,
          password: widget.password,
          siteName: widget.siteName,
          fullName: widget.fullName,
          email: widget.email,
        ),
      ),
    );
  }

  Widget _buildAccountTile() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _navigateTo(context, AccountPage.new),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const CircleAvatar(radius: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.fullName, style: const TextStyle(fontSize: 18, color: Colors.white)),
                  Text(widget.email, style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildProductTiles() {
    if (licensedProductCodes.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.only(bottom: 12.0),
          child: Text('No licensed products found.', style: TextStyle(color: Colors.grey)),
        ),
      ];
    }

    return licensedProductCodes.map((code) {
      final meta = productMeta[code];
      if (meta == null) return const SizedBox.shrink();

      final title = meta['title'] as String;
      final prefix = meta['prefix'] as String;
      final builder = meta['builder'] as Widget Function({required int partyId, required String username, required String password, required String siteName, required String fullName, required String email});

      final flag = productFlags[code] ?? 0;
      final color = flag == 1 ? 'yellow' : flag == 2 ? 'red' : 'green';
      final iconPath = 'assets/images/products/$code/${color}_$prefix.png';

      return ListTile(
        leading: Image.asset(iconPath, height: 28),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        onTap: () => _navigateTo(context, builder),
      );
    }).toList();
  }
}

class _FooterBar extends StatelessWidget {
  final VoidCallback onPrivacy;
  final VoidCallback onLegal;
  final VoidCallback onAcknowledgements;

  const _FooterBar({
    required this.onPrivacy,
    required this.onLegal,
    required this.onAcknowledgements,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _FooterLink(text: 'Privacy', onTap: onPrivacy),
          const _Dot(),
          _FooterLink(text: 'Legal', onTap: onLegal),
          const _Dot(),
          _FooterLink(text: 'Acknowledgments', onTap: onAcknowledgements),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Text('•', style: TextStyle(color: Colors.grey)),
      );
}

class _FooterLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _FooterLink({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
            decoration: TextDecoration.underline,
          ),
        ),
      );
}
