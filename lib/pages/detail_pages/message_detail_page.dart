import 'package:flutter/material.dart';

const darkBackground = Color(0xFF121212);

class MessageDetailPage extends StatelessWidget {
  final List<Map<String, dynamic>> alerts;
  final int currentIndex;

  const MessageDetailPage({
    super.key,
    required this.alerts,
    required this.currentIndex,
  });

  void _navigateTo(BuildContext context, int newIndex) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => MessageDetailPage(
          alerts: alerts,
          currentIndex: newIndex,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final alert = alerts[currentIndex];

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity != null) {
          if (details.primaryVelocity! > 0 && currentIndex > 0) {
            // Swipe Right → Previous
            _navigateTo(context, currentIndex - 1);
          } else if (details.primaryVelocity! < 0 &&
              currentIndex < alerts.length - 1) {
            // Swipe Left → Next
            _navigateTo(context, currentIndex + 1);
          }
        }
      },
      child: Scaffold(
        backgroundColor: darkBackground,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
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
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_left),
                onPressed: currentIndex > 0
                    ? () => _navigateTo(context, currentIndex - 1)
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_right),
                onPressed: currentIndex < alerts.length - 1
                    ? () => _navigateTo(context, currentIndex + 1)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
