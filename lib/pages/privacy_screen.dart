import 'package:flutter/material.dart';
import 'navbar_widget.dart';
import 'alerts_page.dart';
import 'menu_page.dart';
import 'push_notifications_page.dart';

class PrivacyScreen extends StatelessWidget {
  final int partyId;
  final String username;
  final String password;
  final String siteName;
  final String fullName;
  final String email;
  final bool showNavBar;

  const PrivacyScreen({
    super.key,
    required this.partyId,
    required this.username,
    required this.password,
    required this.siteName,
    required this.fullName,
    required this.email,
    this.showNavBar = true,
  });

  static const _bg = Color(0xFF121212);

  // FULL Privacy Statement (exact text you provided)
  static const String _privacyText = '''
Effective Date: July 16 2025

At Surveil.One, your privacy is a top priority. We are committed to protecting the personal information you entrust to us and ensuring transparency in how we collect, use, and safeguard your data.

Information We Collect
We may collect the following types of data:
- Personal Identifiable Information (PII): such as name, email address, phone number.
- Device & Usage Information: including IP address, browser type, device identifiers, and pages accessed.
- Surveillance Data: images, audio, or video footage captured via the platform’s monitoring tools, subject to user settings and legal compliance.
- Location Data: if enabled, real-time location information for enhanced tracking or alerts.

How We Use Your Information
The data we collect may be used to:
- Deliver and improve the services provided by Surveil.One
- Analyze usage to optimize performance and user experience
- Communicate updates, alerts, or policy changes
- Comply with legal obligations and respond to lawful requests

Data Protection & Security
We implement industry-standard security measures including:
- End-to-end encryption for sensitive transmissions
- Secure storage and access controls
- Regular audits and threat assessments

We do not sell or share your data with third parties unless:
- Required by law
- Necessary to operate essential third-party integrations (under strict privacy terms)
- Authorized by you

Your Choices
You have the right to:
- Access, update, or delete your personal data
- Opt out of non-essential communications
- Disable certain tracking or surveillance features via your account settings

Policy Updates
This Privacy Statement may be updated periodically. We will notify users of significant changes via email or on the platform.

Contact Us
If you have questions or concerns regarding your privacy, please contact us at:
Email: privacy@surveil.one
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        centerTitle: true,
        title: const Text('Privacy Policy'),
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
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: SelectableText(
            _privacyText,
            style: TextStyle(color: Colors.white70, height: 1.5),
          ),
        ),
      ),
    );
  }
}
