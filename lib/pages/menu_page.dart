import 'package:flutter/material.dart';
import 'account_page.dart';

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
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Tappable Profile Header Row
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AccountPage()),
                          );
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const CircleAvatar(
                              radius: 28,
                              backgroundImage: NetworkImage(
                                'https://i.pravatar.cc/150?img=3',
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Martin Nguyen',
                                      style: TextStyle(fontSize: 18, color: Colors.white)),
                                  const Text('martin.nguyen@email.com',
                                      style: TextStyle(color: Colors.grey)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: const [
                                      Text(
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        'Action Required',
                                      ),
                                      SizedBox(width: 4),
                                      Icon(Icons.info_outline,
                                          size: 16, color: Colors.blue),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios,
                                color: Colors.white70, size: 16),
                          ],
                        ),
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
                          // Navigate to your MyProductsPage
                        },
                      ),
                    ],
                  ),
                ),

                // 🔽 Bottom section: divider + options
                const Divider(color: Colors.grey),
                ListTile(
                  leading: const Icon(Icons.verified_user, color: Colors.white),
                  title: const Text('Verify Email',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {},
                ),
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.white),
                  title: const Text('Settings',
                      style: TextStyle(color: Colors.white)),
                  onTap: () {},
                ),
              ],
            ),
          ),

          // App Version + Footer
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
