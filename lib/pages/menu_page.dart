import 'package:flutter/material.dart';
import 'account_page.dart';

// Displays the main menu page with options for the user.
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
                      // Tappable Profile Header Row with background on tap
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AccountPage()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const CircleAvatar(
                                radius: 28,
                                backgroundImage: NetworkImage(
                                  'https://media.licdn.com/dms/image/v2/D5603AQGPzsD0Cat56w/profile-displayphoto-shrink_800_800/profile-displayphoto-shrink_800_800/0/1730082888067?e=1755734400&v=beta&t=5D6v0NsddCXrTvRL7T_p9iUGQbi8RHoMNvEP9_S0pZk',
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
                                          'Action Required',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
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
                      ),

                      const SizedBox(height: 24),

                      // My Products Line
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
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

                // Bottom section: divider + options
                const Divider(color: Colors.grey),
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

// Helper widget to create a dot separator
Widget _dotSeparator() {
  return const Padding(
    padding: EdgeInsets.symmetric(horizontal: 8.0),
    child: Text('•', style: TextStyle(color: Colors.grey)),
  );
}

// Custom widget for footer links
class _FooterLink extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _FooterLink({required this.text, required this.onTap});
  
  // Builds a tappable footer link
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
