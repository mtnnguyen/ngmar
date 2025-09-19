import 'package:flutter/material.dart';
import 'graphql_service.dart';
import 'detail_pages/message_detail_page.dart';
import 'navbar_widget.dart';
import 'menu_page.dart';
import 'push_notifications_page.dart';
import 'image_url.dart';

const darkBackground = Color(0xFF121212);
const String kDefaultImageHost = 'http://35.182.97.114';

class AlertsPage extends StatefulWidget {
  const AlertsPage({
    super.key,
    required this.partyId,
    required this.username,
    required this.password,
    required this.siteName,
    required this.fullName,
    required this.email,
  });

  final int partyId;
  final String username;
  final String password;
  final String siteName;
  final String fullName;
  final String email;

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  final List<Map<String, dynamic>> _alerts = [];
  final ScrollController _scrollCtrl = ScrollController();
  bool isLoading = true;

  final String imageHost = kDefaultImageHost;

  // Key to anchor the popup menu under the filter icon
  final GlobalKey _filterKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
  }

  Future<void> _fetchAlerts() async {
    final service = GraphQLService();
    final newAlerts = await service.getAlerts(
      siteName: widget.siteName,
      fromDate: '2025-07-01T00:00:00Z',
      toDate: '2026-08-25T23:59:59Z',
      recordsPerPage: 50, // grab up to 50 at once
    );

    if (newAlerts != null && newAlerts.isNotEmpty) {
      setState(() {
        _alerts.clear();
        _alerts.addAll(newAlerts.map((alert) {
          final rawImg = (alert['image_url'] ?? alert['imageUrl'] ?? alert['thumbnail'])?.toString();
          return {
            ...alert,
            'title': alert['alert_type'] ?? 'Alert',
            'preview': alert['alert_message_code'] ?? alert['alert_message'] ?? 'No message',
            'date': _parseDate(alert['created_at'] ?? alert['createdAt']) ?? DateTime.now(),
            'image_url': normalizeImageUrl(rawImg, imageHost: imageHost, siteName: widget.siteName),
          };
        }));
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  DateTime? _parseDate(dynamic v) {
    if (v is DateTime) return v.toLocal();
    if (v is int) {
      return DateTime.fromMillisecondsSinceEpoch(
        v > 1000000000000 ? v : v * 1000,
        isUtc: true,
      ).toLocal();
    }
    if (v is String) {
      try {
        return DateTime.parse(v.replaceFirst('+00:00', 'Z')).toLocal();
      } catch (_) {}
    }
    return null;
  }

  void _sortAlerts(String order) {
    setState(() {
      _alerts.sort((a, b) =>
          order == 'newest' ? b['date'].compareTo(a['date']) : a['date'].compareTo(b['date']));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Alerts'),
        leading: IconButton(
          key: _filterKey,
          icon: const Icon(Icons.filter_list),
          onPressed: () async {
            final box = _filterKey.currentContext!.findRenderObject() as RenderBox;
            final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

            final position = RelativeRect.fromRect(
              Rect.fromPoints(
                box.localToGlobal(Offset.zero, ancestor: overlay),
                box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
              ),
              Offset.zero & overlay.size,
            );

            final selected = await showMenu<String>(
              context: context,
              position: position,
              items: const [
                PopupMenuItem(value: 'newest', child: Text('Newest to Oldest')),
                PopupMenuItem(value: 'oldest', child: Text('Oldest to Newest')),
              ],
            );
            if (selected != null) _sortAlerts(selected);
          },
        ),
        actions: [
          TopRightNavBar(
            onAlertsTap: () => _sortAlerts('newest'),
            onPushTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PushNotificationsPage(
                            partyId: widget.partyId,
                            username: widget.username,
                            password: widget.password,
                            siteName: widget.siteName,
                            fullName: widget.fullName,
                            email: widget.email,
                          )));
            },
            onMenuTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => MenuPage(
                            partyId: widget.partyId,
                            username: widget.username,
                            password: widget.password,
                            siteName: widget.siteName,
                            fullName: widget.fullName,
                            email: widget.email,
                          )));
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _alerts.isEmpty
              ? const Center(
                  child: Text('No alerts found.', style: TextStyle(color: Colors.white)))
              : ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: _alerts.length,
                  itemBuilder: (context, i) {
                    return _AlertTile(
                      index: i,
                      alert: _alerts[i],
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => MessageDetailPage(
                                      alerts: _alerts,
                                      currentIndex: i,
                                      onBack: () => Navigator.pop(context),
                                      onMarkAsUnread: () {},
                                      onAlertsTap: () {},
                                      onPushTap: () {},
                                      onMenuTap: () {},
                                      siteName: widget.siteName,
                                      imageHost: imageHost,
                                    )));
                      },
                    );
                  },
                ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final int index;
  final Map<String, dynamic> alert;
  final VoidCallback onTap;

  const _AlertTile({required this.index, required this.alert, required this.onTap});

  String _date(DateTime d) {
    final now = DateTime.now();
    final isToday = d.year == now.year && d.month == now.month && d.day == now.day;

    if (isToday) {
      final h = d.hour == 0 ? 12 : (d.hour > 12 ? d.hour - 12 : d.hour);
      final mm = d.minute.toString().padLeft(2, '0');
      final ampm = d.hour >= 12 ? 'PM' : 'AM';
      return '$h:$mm $ampm';
    } else {
      return '${d.month}/${d.day}/${d.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final img = alert['image_url'] as String?;
    final heroTag = 'alert-image-$index';

    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: (img != null && img.isNotEmpty)
            ? Hero(
                tag: heroTag,
                child: Image.network(
                  img,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image, color: Colors.grey),
                ),
              )
            : const Icon(Icons.image_not_supported, size: 28, color: Colors.grey),
      ),
      title: Text(
        alert['title'] ?? 'Alert',
        style: const TextStyle(color: Colors.white),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(_date(alert['date']), style: const TextStyle(color: Colors.grey)),
      onTap: onTap,
    );
  }
}
