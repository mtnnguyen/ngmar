import 'package:flutter/material.dart';

const darkBackground = Color(0xFF121212);

// The main page for alert displaying
class MessageDetailPage extends StatelessWidget {
  final List<Map<String, dynamic>> alerts;
  final int currentIndex;
  final VoidCallback onBack;
  final VoidCallback onMarkAsUnread;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  // Takes a list of alert buttons
  const MessageDetailPage({
    super.key,
    required this.alerts,
    required this.currentIndex,
    required this.onBack,
    required this.onMarkAsUnread,
    required this.onNext,
    required this.onPrevious,
  });

  // Builds the detail page for a specific alert
  @override
  Widget build(BuildContext context) {
    final alert = alerts[currentIndex];
    
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        centerTitle: true,
        title: const Text('Alert Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${alert['date'].month}/${alert['date'].day}/${alert['date'].year}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Text(
              alert['title'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(alert['preview']),
            const SizedBox(height: 24),
            Container(
              color: darkBackground,
              height: 150,
              width: double.infinity,
              child: const Center(child: Text('Display Image')),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onMarkAsUnread,
              icon: const Icon(Icons.markunread),
              label: const Text('Mark as Unread'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_left, size: 40),
              onPressed: currentIndex > 0 ? onPrevious : null,
            ),
            IconButton(
              icon: const Icon(Icons.arrow_right, size: 40),
              onPressed: currentIndex < alerts.length - 1 ? onNext : null,
            ),
          ],
        ),
      ),
    );
  }
}
