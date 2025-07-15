import 'package:flutter/material.dart';
import 'detail_pages/event_detail_page.dart';

const darkBackground = Color(0xFF121212);

class EventsPage extends StatelessWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Events'),
      ),
      body: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.event),
            title: Text('Event ${index + 1}'),
            subtitle: const Text('Tap to view event details'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EventDetailPage()),
              );
            },
          );
        },
      ),
    );
  }
}
