import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text('Menu'),
        actions: [
          Tooltip(
            message: 'This is your account menu.',
            child: IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {},
              splashRadius: 20,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 👤 Profile Header with image
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(
                        'https://i.pravatar.cc/150?img=3',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Martin Nguyen',
                            style: TextStyle(fontSize: 18, color: Colors.white)),
                        Text('martin.nguyen@email.com',
                            style: TextStyle(color: Colors.grey)),
                        SizedBox(height: 4),
                        Text('Action Required',
                            style: TextStyle(color: Colors.blue, fontSize: 12)),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 🛍 My Products Tile
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.electric_bolt, color: Colors.white),
                  title: const Text('My Products',
                      style: TextStyle(color: Colors.white)),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      color: Colors.white70, size: 16),
                  onTap: () {
                    // Navigate to your MyProductsPage or similar
                  },
                ),

                const SizedBox(height: 16),

                const Divider(color: Colors.grey),

                // Optional menu links (if needed)
                ListTile(
                  leading: const Icon(Icons.verified_user, color: Colors.white),
                  title: const Text('Verify Email',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.white),
                  title:
                      const Text('Settings', style: TextStyle(color: Colors.white)),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text('Sign Out',
                      style: TextStyle(color: Colors.redAccent)),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),

          // 📱 App Version + Footer
          Column(
            children: [
              const Text(
                'App Version v4.46.6-3411',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _FooterLink(text: 'Privacy', onTap: () {}),
                    _dotSeparator(),
                    _FooterLink(text: 'Legal', onTap: () {}),
                    _dotSeparator(),
                    _FooterLink(text: 'Acknowledgments', onTap: () {}),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _dotSeparator() {
  return const Padding(
    padding: EdgeInsets.symmetric(horizontal: 8.0),
    child: Text('•', style: TextStyle(color: Colors.grey)),
  );
}

class _FooterLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _FooterLink({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
}
