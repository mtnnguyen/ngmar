import 'package:flutter/material.dart';
import 'navbar_widget.dart';
import 'alerts_page.dart';
import 'menu_page.dart';
import 'push_notifications_page.dart';

class AcknowledgementsScreen extends StatelessWidget {
  final int partyId;
  final String username;
  final String password;
  final String siteName;
  final String fullName;
  final String email;
  final bool showNavBar;

  const AcknowledgementsScreen({
    super.key,
    required this.partyId,
    required this.username,
    required this.password,
    required this.siteName,
    required this.fullName,
    required this.email,
    this.showNavBar = true, // toggle nav bar (hide when launched from Login)
  });

  static const bg = Color(0xFF121212);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        centerTitle: true,
        title: const Text('Acknowledgments'),
        actions: (showNavBar && partyId > 0)
            ? [
                TopRightNavBar(
                  onAlertsTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AlertsPage(
                          partyId: partyId,
                          username: username,
                          password: password,
                          siteName: siteName,
                          fullName: fullName,
                          email: email,
                        ),
                      ),
                    );
                  },
                  onPushTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PushNotificationsPage(
                          partyId: partyId,
                          username: username,
                          password: password,
                          siteName: siteName,
                          fullName: fullName,
                          email: email,
                        ),
                      ),
                    );
                  },
                  onMenuTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MenuPage(
                          partyId: partyId,
                          username: username,
                          password: password,
                          siteName: siteName,
                          fullName: fullName,
                          email: email,
                        ),
                      ),
                    );
                  },
                ),
              ]
            : null,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _Intro(),
          const SizedBox(height: 16),

          // Core Technologies
          const _AckSection(
            title: 'Core Technologies',
            items: [
              _AckItem(
                title: 'Flutter & Dart',
                subtitle: 'The UI toolkit and language powering this app.',
              ),
              _AckItem(
                title: 'GraphQL',
                subtitle: 'Typed APIs for efficient data fetching.',
              ),
              _AckItem(
                title: 'AWS AppSync',
                subtitle: 'Managed GraphQL layer for scalable data operations.',
              ),
              _AckItem(
                title: 'Cloud Object Storage',
                subtitle: 'Asset storage for images and media.',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Packages & Assets
          const _AckSection(
            title: 'Packages & Assets',
            items: [
              _AckItem(
                title: 'Material Icons',
                subtitle: 'Iconography and UI affordances.',
              ),
              _AckItem(
                title: 'Animations & Widgets',
                subtitle: 'Transitions, cards, and layout primitives.',
              ),
              _AckItem(
                title: 'Custom Artwork',
                subtitle: 'Status graphics (green/amber/red) for products.',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Contributors
          const _AckSection(
            title: 'Contributors',
            items: [
              _AckItem(
                title: 'Mobile Engineering',
                subtitle: 'Architecture, state, and UI polish.',
              ),
              _AckItem(
                title: 'Backend & Data',
                subtitle: 'GraphQL schemas, integrations, and observability.',
              ),
              _AckItem(
                title: 'Design & Research',
                subtitle: 'Product experience, motion, and accessibility.',
              ),
              _AckItem(
                title: 'QA & Support',
                subtitle: 'Regression, endpoints, and device coverage.',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Special Thanks
          const _AckSection(
            title: 'Special Thanks',
            items: [
              _AckItem(
                title: 'Early Adopters',
                subtitle: 'For feedback that shaped the roadmap.',
              ),
              _AckItem(
                title: 'Security Reviewers',
                subtitle: 'For guidance on privacy and data practices.',
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Open source licenses
          Center(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.description, color: Colors.white70, size: 18),
              label: const Text('Open Source Licenses',
                  style: TextStyle(color: Colors.white70)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white24),
              ),
              onPressed: () {
                showLicensePage(
                  context: context,
                  applicationName: 'SurveilOne',
                  applicationVersion: 'v4.46.6-3411',
                  applicationLegalese:
                      '© ${DateTime.now().year} SurveilOne. All rights reserved.',
                );
              },
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'We’re grateful to the people, tools, and open technologies that make SurveilOne possible. '
      'This page recognizes the teams, ecosystems, and assets that support the app.',
      style: TextStyle(color: Colors.white70, height: 1.4),
    );
  }
}

class _AckSection extends StatelessWidget {
  final String title;
  final List<_AckItem> items;

  const _AckSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            for (final item in items) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 4.0, right: 10),
                    child: Icon(Icons.brightness_1, size: 6, color: Colors.white54),
                  ),
                  Expanded(child: item),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _AckItem extends StatelessWidget {
  final String title;
  final String subtitle;

  const _AckItem({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$title\n',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          TextSpan(
            text: subtitle,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
