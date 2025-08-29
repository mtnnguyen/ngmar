import 'package:flutter/material.dart';
import 'account_page.dart';
import 'my_products_page.dart';
import 'indoor_surveillance_page.dart';
import 'outdoor_surveillance_page.dart';
import 'employee_time_tracking_page.dart';
import 'pharmacy_governance_page.dart';
import 'graphql_service.dart';
import 'navbar_widget.dart';
import 'alerts_page.dart';

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

  static const productOptions = {
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
    final service = GraphQLService();
    final products = await service.getProducts(
      siteName: widget.siteName,
      partyId: widget.partyId,
    );

    setState(() {
      licensedProductCodes = products ?? [];
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
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
              debugPrint('Push notification tapped');
            },
            onMenuTap: () {},
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AccountPage(
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const CircleAvatar(radius: 28),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(widget.fullName,
                                              style: const TextStyle(fontSize: 18, color: Colors.white)),
                                          Text(widget.email,
                                              style: const TextStyle(color: Colors.grey)),
                                          const SizedBox(height: 4),
                                          const Row(),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.arrow_forward_ios,
                                        color: Colors.white70, size: 16),
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
                              children: licensedProductCodes.map((code) {
                                final product = productOptions[code];
                                final title = product?['title'] ?? code;
                                final iconPath = product?['icon'] ?? '';

                                Widget page;
                                switch (code) {
                                  case 'IND_SUR':
                                    page = IndoorSurveillancePage(
                                      siteName: widget.siteName,
                                      partyId: widget.partyId,
                                      username: widget.username,
                                      password: widget.password,
                                      fullName: widget.fullName,
                                      email: widget.email,
                                    );
                                    break;
                                  case 'OUT_SUR':
                                    page = OutdoorSurveillancePage(
                                      siteName: widget.siteName,
                                      partyId: widget.partyId,
                                      username: widget.username,
                                      password: widget.password,
                                      fullName: widget.fullName,
                                      email: widget.email,
                                    );
                                    break;
                                  case 'TIM_TRA':
                                    page = EmployeeTimeTrackingPage(
                                      siteName: widget.siteName,
                                      partyId: widget.partyId,
                                      username: widget.username,
                                      password: widget.password,
                                      fullName: widget.fullName,
                                      email: widget.email,
                                    );
                                    break;
                                  case 'PHA_GOV':
                                    page = PharmacyGovernancePage(
                                      siteName: widget.siteName,
                                      partyId: widget.partyId,
                                      username: widget.username,
                                      password: widget.password,
                                      fullName: widget.fullName,
                                      email: widget.email,
                                    );
                                    break;
                                  default:
                                    return const SizedBox(); // or just skip rendering unknown product
                                }
                                return ListTile(
                                  leading: iconPath.isNotEmpty
                                      ? Image.asset(iconPath, height: 28)
                                      : const Icon(Icons.circle, size: 10, color: Colors.white54),
                                  title: Text(title, style: const TextStyle(color: Colors.white)),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => page),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: Colors.grey),
                    ],
                  ),
                ),
                Column(
                  children: const [
                    Text(
                      'App Version v4.46.6-3411',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    SizedBox(height: 8),
                    _FooterBar(),
                  ],
                ),
              ],
            ),
    );
  }
}

class _FooterBar extends StatelessWidget {
  const _FooterBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          _FooterLink(text: 'Privacy', onTap: _noop),
          _Dot(),
          _FooterLink(text: 'Legal', onTap: _noop),
          _Dot(),
          _FooterLink(text: 'Acknowledgments', onTap: _noop),
        ],
      ),
    );
  }

  static void _noop() {}
}

class _Dot extends StatelessWidget {
  const _Dot();
  @override
  Widget build(BuildContext context) =>
      const Padding(padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Text('•', style: TextStyle(color: Colors.grey)));
}

class _FooterLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _FooterLink({required this.text, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Text(text,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          decoration: TextDecoration.underline,
        )),
  );
}
