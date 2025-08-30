import 'package:flutter/material.dart';

const darkBackground = Color(0xFF121212);
const String kDefaultImageHost = 'http://35.182.97.114';

class MessageDetailPage extends StatelessWidget {
  final List<Map<String, dynamic>> alerts;
  final int currentIndex;
  final VoidCallback onBack;
  // Kept for caller compatibility; not used in UI.
  final VoidCallback onMarkAsUnread;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onAlertsTap;
  final VoidCallback onPushTap;
  final VoidCallback onMenuTap;

  final String siteName;
  final String imageHost;

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
    required this.siteName,
    this.imageHost = kDefaultImageHost,
  });

  Map<String, dynamic> get _alert => alerts[currentIndex];

  String _formatDateTime(DateTime d) {
    final two = (int n) => n.toString().padLeft(2, '0');
    final h = d.hour == 0 ? 12 : (d.hour > 12 ? d.hour - 12 : d.hour);
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    return '${d.month}/${d.day}/${d.year} • ${two(h)}:${two(d.minute)} $ampm';
  }

  DateTime _pickDate(Map<String, dynamic> a) {
    final v = a['date'] ?? a['timestamp'];
    if (v is DateTime) return v.toLocal();
    if (v is int) {
      final isMs = v > 1000000000000;
      return DateTime.fromMillisecondsSinceEpoch(isMs ? v : v * 1000, isUtc: true).toLocal();
    }
    if (v is String) {
      try { return DateTime.parse(v).toLocal(); } catch (_) {}
      try { return DateTime.parse(v.replaceAll(' ', 'T')).toLocal(); } catch (_) {}
    }
    return DateTime.now();
  }

  String get _imageBase {
    final host = imageHost.endsWith('/') ? imageHost.substring(0, imageHost.length - 1) : imageHost;
    final site = siteName.trim().replaceAll(RegExp(r'^/+|/+$'), '');
    return '$host/images/$site/';
  }

  String? _imageUrl(Map<String, dynamic> a) {
    final raw = (a['image_url'] ?? a['imageUrl'] ?? a['thumbnail'] ?? a['image'] ?? a['img'])?.toString();
    if (raw == null || raw.trim().isEmpty) return null;
    final u = raw.trim();

    // Absolute URL
    if (u.startsWith('http://') || u.startsWith('https://')) {
      if (u.contains('/images/')) {
        final after = u.split('/images/').last;
        final rem = after.startsWith('$siteName/') ? after.substring('$siteName/'.length) : after;
        return '$_imageBase$rem';
      }
      return u; // leave non-/images/ absolutes alone
    }

    // /images/...
    if (u.startsWith('/images/')) {
      final after = u.substring('/images/'.length);
      final rem = after.startsWith('$siteName/') ? after.substring('$siteName/'.length) : after;
      return '$_imageBase$rem';
    }

    // relative CAM_001/...
    return '$_imageBase$u';
  }

  Widget _whatWeSee(Map<String, dynamic> a) {
    // Prefer objects/labels if present
    List<String>? toStrList(dynamic v) =>
        v is List ? v.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).cast<String>().toList() : null;

    final items = (toStrList(a['objects']) ?? toStrList(a['labels'])) ?? const [];
    if (items.isNotEmpty) {
      return Wrap(
        spacing: 8, runSpacing: 8,
        children: items.map((s) => Chip(
          label: Text(s, style: const TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF1F1F1F), side: BorderSide.none,
        )).toList(),
      );
    }

    final raw = (a['alert_message'] ?? a['preview'] ?? a['alert_message_code'] ?? a['description'] ?? '').toString();
    final pretty = raw.replaceAll('_', ' ').trim();
    if (pretty.isEmpty) {
      return const Text('No additional details provided.', style: TextStyle(color: Colors.white70));
    }
    return Text(pretty[0].toUpperCase() + pretty.substring(1), style: const TextStyle(color: Colors.white70));
  }

  List<Widget> _metadataRows(Map<String, dynamic> a) {
    // No map copies, no alt_* filtering loops—just pick known keys directly.
    final pairs = <String, String>{
      'camera': (a['camera'] ?? a['source_camera'] ?? a['cam'])?.toString() ?? '',
      'location': (a['location'] ?? a['site_location'])?.toString() ?? '',
      'severity': (a['severity'] ?? a['level'])?.toString() ?? '',
      'zone': (a['zone'] ?? a['area'])?.toString() ?? '',
      'category': (a['category'] ?? a['type'])?.toString() ?? '',
      'code': (a['code'] ?? a['alert_code'])?.toString() ?? '',
      'id': (a['id'] ?? a['alert_id'])?.toString() ?? '',
    }..removeWhere((_, v) => v.trim().isEmpty);

    if (pairs.isEmpty) return const [];

    return pairs.entries.map((e) => Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            decoration: BoxDecoration(color: const Color(0xFF1F1F1F), borderRadius: BorderRadius.circular(6)),
            child: Text(e.key.toUpperCase(), style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(e.value, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white))),
        ],
      ),
    )).toList();
  }

  void _openImageFullscreen(BuildContext context, String url, String heroTag) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (ctx) => GestureDetector(
        onTap: () => Navigator.of(ctx).pop(),
        child: Stack(
          children: [
            Center(
              child: Hero(
                tag: heroTag,
                child: InteractiveViewer(
                  minScale: 1.0, maxScale: 6.0,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(url, fit: BoxFit.contain, gaplessPlayback: true,
                      errorBuilder: (_, __, ___) => const SizedBox(
                        height: 200, child: Center(child: Text('Failed to load image', style: TextStyle(color: Colors.redAccent))),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(ctx).padding.top + 12, right: 12,
              child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.of(ctx).pop()),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final a = _alert;
    final img = _imageUrl(a);
    final dt = _pickDate(a);
    final heroTag = 'alert-image-$currentIndex';

    return Scaffold(
      backgroundColor: darkBackground,
      body: SafeArea(
        child: GestureDetector(
          // Simple swipe nav
          onHorizontalDragEnd: (d) {
            final v = d.primaryVelocity ?? 0;
            if (v < -200 && currentIndex < alerts.length - 1) onNext();
            if (v > 200 && currentIndex > 0) onPrevious();
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: ListView(
              children: [
                // Header row: back + date
                Row(
                  children: [
                    IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back, color: Colors.white)),
                    const Spacer(),
                    Text(_formatDateTime(dt), style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 8),

                // Title + site chip
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text((a['title'] ?? 'Alert').toString(),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(color: const Color(0xFF1F1F1F), borderRadius: BorderRadius.circular(8)),
                      child: Text(siteName, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                _whatWeSee(a),
                const SizedBox(height: 14),

                if (img != null && img.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Hero(
                      tag: heroTag,
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: InteractiveViewer(
                                minScale: 1.0, maxScale: 4.0,
                                child: Image.network(
                                  img, fit: BoxFit.cover, gaplessPlayback: true,
                                  loadingBuilder: (c, child, lp) => lp == null
                                      ? child
                                      : const Center(child: Padding(
                                          padding: EdgeInsets.all(24),
                                          child: CircularProgressIndicator(color: Colors.white),
                                        )),
                                  errorBuilder: (c, e, s) => Container(
                                    color: const Color(0xFF1A1A1A),
                                    alignment: Alignment.center,
                                    child: const Text('Failed to load image', style: TextStyle(color: Colors.redAccent)),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 8, top: 8,
                              child: IconButton(
                                tooltip: 'Open full screen',
                                icon: const Icon(Icons.open_in_full, color: Colors.white),
                                onPressed: () => _openImageFullscreen(context, img, heroTag),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    height: 180,
                    decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12)),
                    alignment: Alignment.center,
                    child: const Text('No image available', style: TextStyle(color: Colors.white54)),
                  ),

                const SizedBox(height: 16),
                ..._metadataRows(a),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(icon: const Icon(Icons.arrow_left, size: 40), onPressed: currentIndex > 0 ? onPrevious : null, tooltip: 'Previous'),
            IconButton(icon: const Icon(Icons.arrow_right, size: 40), onPressed: currentIndex < alerts.length - 1 ? onNext : null, tooltip: 'Next'),
          ],
        ),
      ),
    );
  }
}
