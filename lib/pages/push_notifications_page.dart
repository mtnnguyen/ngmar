import 'package:flutter/material.dart';
import 'navbar_widget.dart';
import 'alerts_page.dart';
import 'menu_page.dart';
import 'graphql_service.dart';
import 'detail_pages/message_detail_page.dart';

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

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final service = GraphQLService();
    const fromDate = '2025-07-01T00:00:00Z';
    const toDate = '2026-08-25T23:59:59Z';

    final result = await service.getAlerts(
      siteName: widget.siteName,
      fromDate: fromDate,
      toDate: toDate,
    );

    if (mounted) {
      setState(() {
        alerts = (result ?? []).map((alert) {
          DateTime parsed = DateTime.now();
          final created = (alert['created_at'] ?? alert['createdAt'] ?? '').toString();
          try {
            parsed = DateTime.parse(created.replaceFirst('+00:00', 'Z'));
          } catch (_) {}

          return {
            ...alert,
            'title': alert['alert_type'] ?? 'Alert',
            'preview': alert['alert_message_code'] ?? alert['alert_message'] ?? 'No message',
            'date': parsed,
          };
        }).toList();

        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
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
            onPushTap: () {}, // Already here
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
                              onBack: () {}, // No back needed
                              onMarkAsUnread: () {}, // Optional
                              onNext: () {}, // Optional
                              onPrevious: () {}, // Optional
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
                            ),
                          ),
                        );
                      },
                      child: _NotificationCard(
                        title: alert['title'],
                        message: alert['preview'],
                        time: _formatDate(alert['date']),
                      ),
                    );
                  },
                ),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.month}/${d.day}/${d.year}';
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
              Text(
                time,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
