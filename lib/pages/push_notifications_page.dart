import 'package:flutter/material.dart';
import 'navbar_widget.dart';
import 'alerts_page.dart';
import 'menu_page.dart';
import 'graphql_service.dart';
import 'detail_pages/message_detail_page.dart';
import 'image_url.dart';

const darkBackground = Color(0xFF121212);

// Default image host (promote to widget param if you want per-env override)
const String kDefaultImageHost = 'http://35.182.97.114';

class PushNotificationsPage extends StatefulWidget {
  final int partyId;
  final String username;
  final String password;
  final String siteName;
  final String fullName;
  final String email;

  const PushNotificationsPage({
    super.key,
    required this.partyId,
    required this.username,
    required this.password,
    required this.siteName,
    required this.fullName,
    required this.email,
  });

  @override
  State<PushNotificationsPage> createState() => _PushNotificationsPageState();
}

class _PushNotificationsPageState extends State<PushNotificationsPage> {
  List<Map<String, dynamic>> alerts = [];
  bool isLoading = true;

  // Keep consistent with Alerts/Detail pages
  final String imageHost = kDefaultImageHost;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // ---------------------------- Helpers: dates -----------------------------
  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is int) {
      if (value > 1000000000000) {
        return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true).toLocal();
      } else if (value > 1000000000) {
        return DateTime.fromMillisecondsSinceEpoch(value * 1000, isUtc: true).toLocal();
      }
    }
    if (value is String) {
      try {
        return DateTime.parse(value.replaceFirst('+00:00', 'Z')).toLocal();
      } catch (_) {}
    }
    return null;
  }

  String _formatDate(DateTime d) => '${d.month}/${d.day}/${d.year}';

  String? _pickRawImageField(Map<String, dynamic> a) {
    return (a['image_url'] ?? a['imageUrl'] ?? a['thumbnail'] ?? a['image'] ?? a['img'])?.toString();
  }

  // --------------------------------- Data ----------------------------------
  Future<void> _loadNotifications() async {
    final service = GraphQLService();
    const fromDate = '2025-07-01T00:00:00Z';
    const toDate = '2026-08-25T23:59:59Z';

    final result = await service.getAlerts(
      siteName: widget.siteName,
      fromDate: fromDate,
      toDate: toDate,
    );

    if (!mounted) return;

    setState(() {
      alerts = (result ?? []).map((alert) {
        final created = (alert['created_at'] ?? alert['createdAt']);
        final parsed = _parseDate(created) ?? DateTime.now();

        final rawImg = _pickRawImageField(alert);
        // normalize using the shared util
        final fixedImg = normalizeImageUrl(
          rawImg,
          imageHost: imageHost,
          siteName: widget.siteName,
        );

        return {
          ...alert,
          'title': alert['alert_type'] ?? 'Alert',
          'preview': alert['alert_message_code'] ?? alert['alert_message'] ?? 'No message',
          'date': parsed,
          'image_url': fixedImg, // normalized absolute URL
        };
      }).toList();

      isLoading = false;
    });
  }

  // --------------------------------- Build ---------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Push Notifications'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          TopRightNavBar(
            onAlertsTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => AlertsPage(
                    partyId: widget.partyId,
                    username: widget.username,
                    password: widget.password,
                    siteName: widget.siteName,
                    fullName: widget.fullName,
                    email: widget.email,
                  ),
                ),
              );
            },
            onPushTap: () {}, // already here
            onMenuTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => MenuPage(
                    partyId: widget.partyId,
                    username: widget.username,
                    password: widget.password,
                    siteName: widget.siteName,
                    fullName: widget.fullName,
                    email: widget.email,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : alerts.isEmpty
              ? const Center(
                  child: Text(
                    'No push notifications yet.',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: alerts.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final alert = alerts[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MessageDetailPage(
                              alerts: alerts,
                              currentIndex: index,
                              onBack: () => Navigator.pop(context),
                              onMarkAsUnread: () {}, // (optional)
                              onAlertsTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AlertsPage(
                                      partyId: widget.partyId,
                                      username: widget.username,
                                      password: widget.password,
                                      siteName: widget.siteName,
                                      fullName: widget.fullName,
                                      email: widget.email,
                                    ),
                                  ),
                                );
                              },
                              onPushTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PushNotificationsPage(
                                      partyId: widget.partyId,
                                      username: widget.username,
                                      password: widget.password,
                                      siteName: widget.siteName,
                                      fullName: widget.fullName,
                                      email: widget.email,
                                    ),
                                  ),
                                );
                              },
                              onMenuTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MenuPage(
                                      partyId: widget.partyId,
                                      username: widget.username,
                                      password: widget.password,
                                      siteName: widget.siteName,
                                      fullName: widget.fullName,
                                      email: widget.email,
                                    ),
                                  ),
                                );
                              },
                              // pass dynamic site + host to detail page
                              siteName: widget.siteName,
                              imageHost: imageHost,
                            ),
                          ),
                        );
                      },
                      child: _NotificationCard(
                        title: (alert['title'] ?? 'Alert').toString(),
                        message: (alert['preview'] ?? '').toString(),
                        time: _formatDate(alert['date'] as DateTime),
                      ),
                    );
                  },
                ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String title;
  final String message;
  final String time;

  const _NotificationCard({
    required this.title,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
