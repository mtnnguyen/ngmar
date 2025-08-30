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

// NEW: policy pages
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
  List<String> licensedProductCodes = [];
  bool isLoading = true;

  static const Map<String, Map<String, String>> productOptions = {
    'IND_SUR': {
      'title': 'Indoor Surveillance',
      'icon': 'assets/images/products/IND_SUR/green_ind.png',
    },
    'OUT_SUR': {
      'title': 'Outdoor Surveillance',
      'icon': 'assets/images/products/OUT_SUR/green_out.png',
    },
    'TIM_TRA': {
      'title': 'Employee Time Tracking',
      'icon': 'assets/images/products/TIM_TRA/green_tim.png',
    },
    'PHA_GOV': {
      'title': 'Pharmacy Governance',
      'icon': 'assets/images/products/PHA_GOV/green_phar.png',
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
      final service = GraphQLService();
      final products = await service.getProducts(
        siteName: widget.siteName,
        partyId: widget.partyId,
      );
      if (!mounted) return;
      setState(() => licensedProductCodes = products ?? []);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load products: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget? _buildProductPage(String code) {
    switch (code) {
      case 'IND_SUR':
        return IndoorSurveillancePage(
          siteName: widget.siteName,
          partyId: widget.partyId,
          username: widget.username,
          password: widget.password,
          fullName: widget.fullName,
          email: widget.email,
        );
      case 'OUT_SUR':
        return OutdoorSurveillancePage(
          siteName: widget.siteName,
          partyId: widget.partyId,
          username: widget.username,
          password: widget.password,
          fullName: widget.fullName,
          email: widget.email,
        );
      case 'TIM_TRA':
        return EmployeeTimeTrackingPage(
          siteName: widget.siteName,
          partyId: widget.partyId,
          username: widget.username,
          password: widget.password,
          fullName: widget.fullName,
          email: widget.email,
        );
      case 'PHA_GOV':
        return PharmacyGovernancePage(
          siteName: widget.siteName,
          partyId: widget.partyId,
          username: widget.username,
          password: widget.password,
          fullName: widget.fullName,
          email: widget.email,
        );
      default:
        return null;
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
            onPushTap: () {
              Navigator.push(
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
              );
            },
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
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AccountPage(
                            fullName: widget.fullName,
                            email: widget.email,
                            partyId: widget.partyId,
                            username: widget.username,
                            password: widget.password,
                            siteName: widget.siteName,
                          ),
                        ),
                      );
                    },
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
                                Text(widget.fullName,
                                    style: const TextStyle(fontSize: 18, color: Colors.white)),
                                Text(widget.email, style: const TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                        ],
                      ),
                    ),
                  ),
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
            const Text(
              'App Version v4.46.6-3411',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            _FooterBar(
              onPrivacy: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PrivacyScreen(
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
              onLegal: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LegalScreen(
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
              onAcknowledgements: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AcknowledgementsScreen(
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
      final meta = productOptions[code];
      final title = meta?['title'] ?? code;
      final iconPath = meta?['icon'];

      final page = _buildProductPage(code);
      if (page == null) return const SizedBox.shrink();

      return ListTile(
        leading: (iconPath != null && iconPath.isNotEmpty)
            ? Image.asset(iconPath, height: 28)
            : const Icon(Icons.circle, size: 10, color: Colors.white54),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
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
