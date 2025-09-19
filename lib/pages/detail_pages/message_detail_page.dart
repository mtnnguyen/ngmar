import 'package:flutter/material.dart';

const darkBackground = Color(0xFF121212);
const String kDefaultImageHost = 'http://35.182.97.114';

class MessageDetailPage extends StatefulWidget {
  final List<Map<String, dynamic>> alerts;
  final int currentIndex;
  final VoidCallback onBack;
  final VoidCallback onMarkAsUnread;
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
    required this.onAlertsTap,
    required this.onPushTap,
    required this.onMenuTap,
    required this.siteName,
    this.imageHost = kDefaultImageHost,
  });

  @override
  State<MessageDetailPage> createState() => _MessageDetailPageState();
}

class _MessageDetailPageState extends State<MessageDetailPage> {
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.currentIndex;
  }

  void _goNext() {
    if (currentIndex < widget.alerts.length - 1) {
      setState(() {
        currentIndex++;
      });
    }
  }

  void _goPrevious() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    }
  }

  Map<String, dynamic> get _alert => widget.alerts[currentIndex];

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
      try {
        return DateTime.parse(v).toLocal();
      } catch (_) {}
      try {
        return DateTime.parse(v.replaceAll(' ', 'T')).toLocal();
      } catch (_) {}
    }
    return DateTime.now();
  }

  String get _imageBase {
    final host = widget.imageHost.endsWith('/') ? widget.imageHost.substring(0, widget.imageHost.length - 1) : widget.imageHost;
    final site = widget.siteName.trim().replaceAll(RegExp(r'^/+|/+$'), '');
    return '$host/images/$site/';
  }

  String? _imageUrl(Map<String, dynamic> a) {
    final raw = (a['image_url'] ?? a['imageUrl'] ?? a['thumbnail'] ?? a['image'] ?? a['img'])?.toString();
    if (raw == null || raw.trim().isEmpty) return null;

    final trimmed = raw.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      final uri = Uri.tryParse(trimmed);
      if (uri == null || uri.host.isEmpty) return null;

      if (uri.host.contains('your-server')) {
        final cleanedPath = uri.path.replaceFirst('/images/', '');
        return '$_imageBase$cleanedPath';
      }

      if (uri.path.contains('/images/')) {
        final after = uri.path.split('/images/').last;
        final cleaned = after.startsWith('${widget.siteName}/') ? after.substring('${widget.siteName}/'.length) : after;
        return '$_imageBase$cleaned';
      }

      return trimmed;
    }

    if (trimmed.startsWith('/images/')) {
      final after = trimmed.substring('/images/'.length);
      final cleaned = after.startsWith('${widget.siteName}/') ? after.substring('${widget.siteName}/'.length) : after;
      return '$_imageBase$cleaned';
    }

    return '$_imageBase$trimmed';
  }

  Widget _whatWeSee(Map<String, dynamic> a) {
    List<String>? toStrList(dynamic v) =>
        v is List ? v.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).cast<String>().toList() : null;

    final items = (toStrList(a['objects']) ?? toStrList(a['labels'])) ?? const [];
    if (items.isNotEmpty) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: items
            .map((s) => Chip(
                  label: Text(s, style: const TextStyle(color: Colors.white)),
                  backgroundColor: const Color(0xFF1F1F1F),
                  side: BorderSide.none,
                ))
            .toList(),
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
    final pairs = <String, String>{
      'camera': (a['camera'] ?? a['source_camera'] ?? a['cam'])?.toString() ?? '',
      'location': (a['location'] ?? a['site_location'])?.toString() ?? '',
      'severity': (a['severity'] ?? a['level'])?.toString() ?? '',
      'zone': (a['zone'] ?? a['area'])?.toString() ?? '',
      'category': (a['category'] ?? a['type'])?.toString() ?? '',
      'code': (a['code'] ?? a['alert_code'])?.toString() ?? '',
    }..removeWhere((_, v) => v.trim().isEmpty);

    return pairs.entries
        .map(
          (e) => Padding(
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
          ),
        )
        .toList();
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
                  minScale: 1.0,
                  maxScale: 6.0,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      gaplessPlayback: true,
                      errorBuilder: (_, __, ___) => const SizedBox(
                        height: 200,
                        child: Center(child: Text('Failed to load image', style: TextStyle(color: Colors.redAccent))),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(ctx).padding.top + 12,
              right: 12,
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
          onHorizontalDragEnd: (d) {
            final v = d.primaryVelocity ?? 0;
            if (v < -200 && currentIndex < widget.alerts.length - 1) _goNext();
            if (v > 200 && currentIndex > 0) _goPrevious();
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                Row(
                  children: [
                    IconButton(onPressed: widget.onBack, icon: const Icon(Icons.arrow_back, color: Colors.white)),
                    const Spacer(),
                    Text(_formatDateTime(dt), style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text((a['title'] ?? 'Alert').toString(),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                                minScale: 1.0,
                                maxScale: 4.0,
                                child: Image.network(
                                  img,
                                  fit: BoxFit.cover,
                                  gaplessPlayback: true,
                                  loadingBuilder: (c, child, lp) =>
                                      lp == null ? child : const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator(color: Colors.white))),
                                  errorBuilder: (c, e, s) => Container(
                                    color: const Color(0xFF1A1A1A),
                                    alignment: Alignment.center,
                                    child: const Text('Failed to load image', style: TextStyle(color: Colors.redAccent)),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
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
            IconButton(icon: const Icon(Icons.arrow_left, size: 40), onPressed: currentIndex > 0 ? _goPrevious : null, tooltip: 'Previous'),
            IconButton(icon: const Icon(Icons.arrow_right, size: 40), onPressed: currentIndex < widget.alerts.length - 1 ? _goNext : null, tooltip: 'Next'),
          ],
        ),
      ),
    );
  }
}
