import 'package:flutter/material.dart';
import 'login_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

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
        title: const Text('Martin Nguyen'),
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
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(Icons.add, size: 18, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Verify Email card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.blue),
                title: const Text(
                  'Verify Email',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Verify your sign in email to secure your Account',
                  style: TextStyle(color: Colors.white70),
                ),
                trailing: const Icon(Icons.arrow_forward_ios,
                    color: Colors.white54, size: 16),
                onTap: () {
                  // Implement verify email logic here
                },
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Account Options
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                _AccountOption(
                  icon: Icons.person_outline,
                  label: 'Personal Information',
                  onTap: () {},
                ),
                _AccountOption(
                  icon: Icons.notifications_none,
                  label: 'Notifications',
                  onTap: () {},
                ),
                _AccountOption(
                  icon: Icons.lock_outline,
                  label: 'Security & Privacy',
                  onTap: () {},
                ),
              ],
            ),
          ),

          // Sign Out – styled container with red on tap
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              splashColor: Colors.redAccent.withOpacity(0.3),
              onTap: () {
                // Simulate logout
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
