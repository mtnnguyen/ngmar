import 'package:flutter/material.dart';
import 'graphql_service.dart';
import 'detail_pages/message_detail_page.dart';
import 'navbar_widget.dart';
import 'menu_page.dart';
import 'push_notifications_page.dart';

const darkBackground = Color(0xFF121212);

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
  final GlobalKey _filterKey = GlobalKey();
  List<Map<String, dynamic>> filteredAlerts = [];
  int? selectedIndex;
  bool isLoading = true;
  String? fullName;
  String? email;

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
  }

  String? _imageUrl(Map<String, dynamic> a) {
    return (a['image_url'] ?? a['imageUrl'] ?? a['thumbnail'] ?? a['image'] ?? a['img'])?.toString();
  }

  Future<void> _fetchAlerts() async {
    final service = GraphQLService();
    const fromDate = '2025-07-01T00:00:00Z';
    const toDate = '2026-08-25T23:59:59Z';

    final alerts = await service.getAlerts(
      siteName: widget.siteName,
      fromDate: fromDate,
      toDate: toDate,
    );

    setState(() {
      filteredAlerts = (alerts != null && alerts.isNotEmpty)
          ? alerts.map((alert) {
              DateTime parsed = DateTime.now();
              final created = (alert['created_at'] ?? alert['createdAt'] ?? '').toString();
              try {
                parsed = DateTime.parse(created.replaceFirst('+00:00', 'Z'));
              } catch (_) {}

              return {
                ...alert,
                'title': alert['alert_type'] ?? 'Alert',
                'preview': alert['alert_message_code'] ?? alert['alert_message'] ?? 'No message',
                'read': false,
                'date': parsed,
                'image_url': _imageUrl(alert),
              };
            }).toList()
          : [
              {
                'title': 'No alerts found',
                'preview': 'No alerts found between the selected dates.',
                'read': false,
                'date': DateTime.now(),
                'image_url': null,
              }
            ];
      isLoading = false;

      fullName = widget.fullName;
      email = widget.email;
    });
  }

  void _sortAlerts(String order) {
    setState(() {
      filteredAlerts.sort((a, b) =>
          order == 'newest' ? b['date'].compareTo(a['date']) : a['date'].compareTo(b['date']));
    });
  }

  void _openDetail(int index) {
    setState(() {
      filteredAlerts[index] = {...filteredAlerts[index], 'read': true};
      selectedIndex = index;
    });
  }

  void _goBack() => setState(() => selectedIndex = null);

  void _markAsUnread(int index) {
    setState(() {
      filteredAlerts[index] = {...filteredAlerts[index], 'read': false};
      selectedIndex = null;
    });
  }

  void _goToNextAlert() {
    if (selectedIndex != null && selectedIndex! < filteredAlerts.length - 1) {
      setState(() {
        selectedIndex = selectedIndex! + 1;
        filteredAlerts[selectedIndex!] = {...filteredAlerts[selectedIndex!], 'read': true};
      });
    }
  }

  void _goToPreviousAlert() {
    if (selectedIndex != null && selectedIndex! > 0) {
      setState(() {
        selectedIndex = selectedIndex! - 1;
        filteredAlerts[selectedIndex!] = {...filteredAlerts[selectedIndex!], 'read': true};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return selectedIndex != null ? _buildDetailView() : _buildAlertList();
  }

  Widget _buildDetailView() {
    return MessageDetailPage(
      alerts: filteredAlerts,
      currentIndex: selectedIndex!,
      onBack: _goBack,
      onMarkAsUnread: () => _markAsUnread(selectedIndex!),
      onNext: _goToNextAlert,
      onPrevious: _goToPreviousAlert,
      onAlertsTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AlertsPage(
              partyId: widget.partyId,
              username: widget.username,
              password: widget.password,
              siteName: widget.siteName,
              fullName: fullName ?? widget.username,
              email: email ?? '',
            ),
          ),
        );
      },
      onPushTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PushNotificationsPage(
              partyId: widget.partyId,
              username: widget.username,
              password: widget.password,
              siteName: widget.siteName,
              fullName: fullName ?? widget.username,
              email: email ?? '',
            ),
          ),
        );
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
              fullName: fullName ?? widget.username,
              email: email ?? '',
            ),
          ),
        );
      },
    );
  }

  Widget _buildAlertList() {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Alerts'),
        leading: IconButton(
          key: _filterKey,
          icon: const Icon(Icons.filter_list),
          onPressed: () async {
            final RenderBox button = _filterKey.currentContext!.findRenderObject() as RenderBox;
            final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
            final Offset position = button.localToGlobal(Offset.zero, ancestor: overlay);

            final RelativeRect positionRect = RelativeRect.fromLTRB(
              position.dx,
              position.dy + button.size.height,
              overlay.size.width - position.dx - button.size.width,
              0,
            );

            final selected = await showMenu<String>(
              context: context,
              position: positionRect,
              items: const [
                PopupMenuItem(value: 'newest', child: Text('Newest to Oldest')),
                PopupMenuItem(value: 'oldest', child: Text('Oldest to Newest')),
              ],
            );

            if (selected != null) _sortAlerts(selected);
          },
          tooltip: 'Sort Alerts',
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
                    fullName: fullName ?? widget.username,
                    email: email ?? '',
                  ),
                ),
              );
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
                    fullName: fullName ?? widget.username,
                    email: email ?? '',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : filteredAlerts.isEmpty
              ? const Center(
                  child: Text('No alerts found.', style: TextStyle(color: Colors.white)),
                )
              : SafeArea(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: filteredAlerts.length,
                    itemBuilder: (context, index) => _AlertTile(
                      index: index,
                      alert: filteredAlerts[index],
                      onTap: () => _openDetail(index),
                    ),
                  ),
                ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final int index;
  final Map<String, dynamic> alert;
  final VoidCallback onTap;

  const _AlertTile({
    required this.index,
    required this.alert,
    required this.onTap,
  });

  String _date(DateTime d) => '${d.month}/${d.day}/${d.year}';

  @override
  Widget build(BuildContext context) {
    final img = (alert['image_url'] as String?);
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
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, color: Colors.grey),
                ),
              )
            : const Icon(Icons.image_not_supported, size: 28, color: Colors.grey),
      ),
      title: Text(
        (alert['title'] ?? 'Alert').toString(),
        style: const TextStyle(color: Colors.white),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        (alert['preview'] ?? '').toString(),
        style: const TextStyle(color: Colors.white70),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        _date(alert['date'] as DateTime),
        style: const TextStyle(color: Colors.grey),
      ),
      onTap: onTap,
    );
  }
}
