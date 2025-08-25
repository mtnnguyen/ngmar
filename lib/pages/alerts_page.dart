import 'package:flutter/material.dart';
import 'graphql_service.dart';
import 'detail_pages/message_detail_page.dart';
import 'menu_page.dart';

const darkBackground = Color(0xFF121212);

/// AlertsPage displays a list of alerts with options to filter, sort, and view details.
class AlertsPage extends StatefulWidget {
  const AlertsPage({
    super.key,
    required this.partyId,
    required this.username,
    required this.password,
    required this.siteName,
  });

  final int partyId;
  final String username;
  final String password;
  final String siteName;

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  final GlobalKey _filterKey = GlobalKey();
  List<Map<String, dynamic>> filteredAlerts = [];
  int? selectedIndex;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAlerts();
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
              return {
                ...alert,
                'title': alert['alert_type'] ?? 'Alert',
                'preview': alert['alert_message_code'] ?? 'No message code',
                'read': false,
                'date': DateTime.tryParse(
                      alert['created_at']?.replaceFirst(RegExp(r'\+00:00\$'), 'Z') ?? '',
                    ) ??
                    DateTime.now(),
              };
            }).toList()
          : [
              {
                'title': 'No alerts found',
                'preview': 'No alerts found between July 25 and Aug 3.',
                'read': false,
                'date': DateTime.now(),
                'image_url': null,
              }
            ];
      isLoading = false;
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
        filteredAlerts[selectedIndex!] = {
          ...filteredAlerts[selectedIndex!],
          'read': true,
        };
      });
    }
  }

  void _goToPreviousAlert() {
    if (selectedIndex != null && selectedIndex! > 0) {
      setState(() {
        selectedIndex = selectedIndex! - 1;
        filteredAlerts[selectedIndex!] = {
          ...filteredAlerts[selectedIndex!],
          'read': true,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return selectedIndex != null ? _buildDetailView() : _buildAlertList();
  }

  Widget _buildDetailView() {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        backgroundColor: darkBackground,
        title: const Text('Message Detail'),
      ),
      body: MessageDetailPage(
        alerts: filteredAlerts,
        currentIndex: selectedIndex!,
        onBack: _goBack,
        onMarkAsUnread: () => _markAsUnread(selectedIndex!),
        onNext: _goToNextAlert,
        onPrevious: _goToPreviousAlert,
      ),
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
            final RenderBox button =
                _filterKey.currentContext!.findRenderObject() as RenderBox;
            final RenderBox overlay =
                Overlay.of(context).context.findRenderObject() as RenderBox;
            final Offset position =
                button.localToGlobal(Offset.zero, ancestor: overlay);

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
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MenuPage(
                    partyId: widget.partyId,
                    username: widget.username,
                    password: widget.password,
                    siteName: widget.siteName,
                  ),
                ),
              );
            },
            tooltip: 'Menu',
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
                      alert: filteredAlerts[index],
                      onTap: () => _openDetail(index),
                    ),
                  ),
                ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final Map<String, dynamic> alert;
  final VoidCallback onTap;

  const _AlertTile({required this.alert, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: alert['image_url'] != null
            ? Image.network(
                alert['image_url'],
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.broken_image, color: Colors.grey),
              )
            : const Icon(Icons.image_not_supported, size: 30, color: Colors.grey),
      ),
      title: Text(alert['title'], style: const TextStyle(color: Colors.white)),
      subtitle: Text(alert['preview'], style: const TextStyle(color: Colors.white70)),
      trailing: Text(
        '${alert['date'].month}/${alert['date'].day}/${alert['date'].year}',
        style: const TextStyle(color: Colors.grey),
      ),
      onTap: onTap,
    );
  }
}
