import 'package:flutter/material.dart';
import 'navbar_widget.dart';
import 'alerts_page.dart';
import 'menu_page.dart';
import 'push_notifications_page.dart';

class LegalScreen extends StatelessWidget {
  final int partyId;
  final String username;
  final String password;
  final String siteName;
  final String fullName;
  final String email;

  const LegalScreen({
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
  static const String _legalText = r"""
Legal Statement of Terms of Use for surveil.one
Effective Date: July 16, 2025
By accessing or using surveil.one ("the Service"), you ("the Use...ent of Use. Please read these terms carefully before proceeding.
Acceptance of Terms
Use of surveil.one constitutes acceptance of all applicable laws...rms. If you do not agree to these terms, do not use the Service.
Authorized Use
You agree to:
Use the Service only for lawful purposes
Operate the surveillance tools within legal boundaries, including obtaining consent where necessary
Respect privacy rights and refrain from unauthorized recording or monitoring
surveil.one reserves the right to revoke access for violations of these terms.
Prohibited Conduct
Users may not:
Interfere with or disrupt the Service infrastructure
Attempt unauthorized access to system data or third-party accounts
Use the Service for unlawful, harassing, invasive, or fraudulent purposes
...
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
These Terms are governed by the laws of Ontario, Canada. Dispute...of the Service shall be resolved in the courts of Richmond Hill.
Modifications
surveil.one reserves the right to modify this Legal Statement of...the Service after changes indicates acceptance of those changes.
""";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        centerTitle: true,
        title: const Text('Legal'),
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
            _legalText,
            style: TextStyle(color: Colors.white70, height: 1.35),
          ),
        ),
      ),
    );
  }
}
