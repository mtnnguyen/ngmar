import 'package:flutter/material.dart';
import 'detail_pages/action_detail_page.dart';

const darkBackground = Color(0xFF121212);

class ActionsPage extends StatelessWidget {
  const ActionsPage({super.key});

  // Creates a list of actions and displays them
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Actions'),
      ),
      body: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.check_circle_outline),
            title: Text('Action Item ${index + 1}'),
            subtitle: const Text('Tap to view more details'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ActionDetailPage()),
              );
            },
          );
        },
      ),
    );
  }
}
