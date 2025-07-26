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
            Text(
              alert['preview'],
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),

            // ✅ Display alert image if available
            if (alert['image_url'] != null && alert['image_url'].toString().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  alert['image_url'],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Text('Failed to load image', style: TextStyle(color: Colors.redAccent)),
                  ),
                ),
              )
            else
              const Text('No image available', style: TextStyle(color: Colors.white54)),

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
