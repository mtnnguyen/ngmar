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

  const PrivacyScreen({
    super.key,
    required this.partyId,
    required this.username,
    required this.password,
    required this.siteName,
    required this.fullName,
    required this.email,
  });

  static const _bg = Color(0xFF121212);

  // EXACT text from the doc
  static const String _privacyText = r"""
Privacy Statement for surveil.one
Effective Date: July 16 2025
At surveil.one, your privacy is a top priority. We are committed...ng transparency in how we collect, use, and safeguard your data.
Information We Collect
We may collect the following types of data:
Personal Identifiable Information (PII): such as name, email address, phone number.
Device & Usage Information: including IP address, browser type, device identifiers, and pages accessed.
Surveillance Data: images, audio, or video footage captured via ...monitoring tools, subject to user settings and legal compliance.
Location Data: if enabled, real-time location information for enhanced tracking or alerts.
How We Use Your Information
The data we collect may be used to:
Deliver and improve the services provided by surveil.one
Analyze usage to optimize performance and user experience
Communicate updates, alerts, or policy changes
Comply with legal obligations and respond to lawful requests
...
Protecting access credentials and system configurations
Ensuring proper data retention and disposal practices
surveil.one assumes no liability for data misuse or unauthorized disclosure caused by user negligence.
Disclaimer of Warranties
The Service is provided “as is” and “as available.” surveil.one ... warranties, expressed or implied, including but not limited to:
Fitness for a particular purpose
Accuracy of data analysis
Uninterrupted service availability
Limitation of Liability
To the fullest extent permitted by law, surveil.one shall not be liable for:
Any direct, indirect, incidental, or consequential damages
Loss of data, profits, or privacy
System failures or security breaches caused by third parties
Jurisdiction
These Terms are governed by the laws of Ontario,
""";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        centerTitle: true,
        title: const Text('Privacy Policy'),
        actions: [
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
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: SelectableText(
            _privacyText,
            style: TextStyle(color: Colors.white70, height: 1.35),
          ),
        ),
      ),
    );
  }
}
