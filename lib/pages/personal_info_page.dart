import 'package:flutter/material.dart';

class PersonalInfoPage extends StatelessWidget {
  final String fullName;
  final String email;

  const PersonalInfoPage({super.key, required this.fullName, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Personal Info"),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _infoTile("Full Name", fullName),
          const Divider(color: Colors.white10),
          _infoTile("Email", email),
          const Divider(color: Colors.white10),
        ],
      ),
    );
  }

  Widget _infoTile(String title, String value) => ListTile(
        title: Text(title, style: const TextStyle(color: Colors.white54)),
        subtitle: Text(value, style: const TextStyle(color: Colors.white)),
      );
}
