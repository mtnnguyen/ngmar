import 'package:flutter/material.dart';
import '../navbar_widget.dart'; // ✅ Relative path to navbar widget

const darkBackground = Color(0xFF121212);

class MessageDetailPage extends StatelessWidget {
  final List<Map<String, dynamic>> alerts;
  final int currentIndex;
  final VoidCallback onBack;
  final VoidCallback onMarkAsUnread;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onAlertsTap;
  final VoidCallback onPushTap;
  final VoidCallback onMenuTap;

  const MessageDetailPage({
    super.key,
    required this.alerts,
    required this.currentIndex,
    required this.onBack,
    required this.onMarkAsUnread,
    required this.onNext,
    required this.onPrevious,
    required this.onAlertsTap,
    required this.onPushTap,
    required this.onMenuTap,
  });

  Map<String, dynamic> get _alert => alerts[currentIndex];

  String _formatDate(DateTime d) => '${d.month}/${d.day}/${d.year}';

  String? fixImageUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) return url;
    return 'https://your-api-or-cdn-url.com$url'; // 🔁 Replace this with actual base URL
  }

  String? _imageUrl(Map<String, dynamic> a) {
    final raw = (a['image_url'] ?? a['imageUrl'] ?? a['thumbnail'] ?? a['image'] ?? a['img'])?.toString();
    return fixImageUrl(raw);
  }

  Widget _whatWeSee(Map<String, dynamic> a) {
    final List<String>? objects = (a['objects'] as List?)?.cast<String>();
    final List<String>? labels = (a['labels'] as List?)?.cast<String>();
    final items = objects ?? labels;

    if (items != null && items.isNotEmpty) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items.map((s) => Chip(
          label: Text(s, style: const TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF1F1F1F),
          side: BorderSide.none,
        )).toList(),
      );
    }

    final raw = (a['alert_message'] ?? a['preview'] ?? a['alert_message_code'] ?? '').toString();
    final pretty = raw.replaceAll('_', ' ').trim();
    if (pretty.isEmpty) {
      return const Text('No additional details provided.', style: TextStyle(color: Colors.white70));
    }
    return Text(pretty[0].toUpperCase() + pretty.substring(1), style: const TextStyle(color: Colors.white70));
  }

  @override
  Widget build(BuildContext context) {
    final alert = _alert;
    final img = _imageUrl(alert);
    final heroTag = 'alert-image-$currentIndex';

    return Scaffold(
      backgroundColor: darkBackground,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            child: ListView(
              children: [
                Text(_formatDate(alert['date'] as DateTime), style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                Text(
                  (alert['title'] ?? 'Alert').toString(),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('What we see', style: TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                _whatWeSee(alert),
                const SizedBox(height: 16),
                if (img != null && img.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Hero(
                      tag: heroTag,
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: InteractiveViewer(
                          minScale: 1.0,
                          maxScale: 4.0,
                          child: Image.network(
                            img,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) =>
                                loadingProgress == null
                                    ? child
                                    : const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(24),
                                          child: CircularProgressIndicator(color: Colors.white),
                                        ),
                                      ),
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: const Color(0xFF1A1A1A),
                              alignment: Alignment.center,
                              child: const Text('Failed to load image', style: TextStyle(color: Colors.redAccent)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text('No image available', style: TextStyle(color: Colors.white54)),
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
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            right: 8,
            child: TopRightNavBar(
              onAlertsTap: onAlertsTap,
              onPushTap: onPushTap,
              onMenuTap: onMenuTap,
            ),
          ),
        ],
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
