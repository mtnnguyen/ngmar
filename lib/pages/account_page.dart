// lib/pages/account_page.dart
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'personal_info_page.dart';
import 'notifications_page.dart';
import 'security_privacy_page.dart';
import 'push_notifications_page.dart';
import 'graphql_service.dart';

class AccountPage extends StatelessWidget {
  final String fullName;
  final String email;
  final int partyId;
  final String username;
  final String password;
  final String siteName;

  const AccountPage({
    super.key,
    required this.fullName,
    required this.email,
    required this.partyId,
    required this.username,
    required this.password,
    required this.siteName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(fullName),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, size: 40, color: Colors.black),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                _AccountOption(
                  icon: Icons.person_outline,
                  label: 'Personal Information',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PersonalInfoPage(
                        fullName: fullName,
                        email: email,
                      ),
                    ),
                  ),
                ),
                _AccountOption(
                  icon: Icons.notifications_none,
                  label: 'Notifications',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationsPage(
                        partyId: partyId,
                        username: username,
                        password: password,
                        siteName: siteName,
                        fullName: fullName,
                        email: email,
                      ),
                    ),
                  ),
                ),
                _AccountOption(
                  icon: Icons.lock_outline,
                  label: 'Security & Privacy',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SecurityPrivacyPage(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              splashColor: Colors.redAccent.withOpacity(0.3),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AccountOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.arrow_forward_ios,
          color: Colors.white54, size: 16),
      onTap: onTap,
    );
  }
}
