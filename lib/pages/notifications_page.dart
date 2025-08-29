// lib/pages/notifications_page.dart
import 'package:flutter/material.dart';
import 'push_notifications_page.dart';

class NotificationsPage extends StatelessWidget {
  final int partyId;
  final String username;
  final String password;
  final String siteName;
  final String fullName;
  final String email;

  const NotificationsPage({
    super.key,
    required this.partyId,
    required this.username,
    required this.password,
    required this.siteName,
    required this.fullName,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PushNotificationsPage(
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
          child: const Text('Go to Push Notifications'),
        ),
      ),
    );
  }
}
