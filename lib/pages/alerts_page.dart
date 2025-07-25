import 'package:flutter/material.dart';
import 'detail_pages/message_detail_page.dart';
import 'menu_page.dart';
import 'alerts_data.dart';

const darkBackground = Color(0xFF121212);

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}


// Displays a list of alerts with options to sort and view details.
class _AlertsPageState extends State<AlertsPage> {
  final GlobalKey _filterKey = GlobalKey();
  late List<Map<String, dynamic>> filteredAlerts;
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    filteredAlerts = List.from(allAlerts);
  }

  // Sorts alerts based on the selected order
  void _sortAlerts(String order) {
    setState(() {
      filteredAlerts.sort((a, b) =>
          order == 'newest' ? b['date'].compareTo(a['date']) : a['date'].compareTo(b['date']));
    });
  }

  // Opens the detail view for a selected alert
  void _openDetail(int index) {
    setState(() {
      filteredAlerts[index] = {...filteredAlerts[index], 'read': true};
      selectedIndex = index;
    });
  }
  // Goes back to the list view
  void _goBack() => setState(() => selectedIndex = null);

  // Marks an alert as unread
  void _markAsUnread(int index) {
    setState(() {
      filteredAlerts[index] = {...filteredAlerts[index], 'read': false};
      selectedIndex = null;
    });
  }

  // Navigates to the next or previous alert
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

  // Builds the main UI for the Alerts page
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

  // Builds the list of alerts with sorting and filtering options
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
                MaterialPageRoute(builder: (context) => const MenuPage()),
              );
            },
            tooltip: 'Menu',
          ),
        ],
      ),
      body: filteredAlerts.isEmpty
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


// Single alert tile in the list
class _AlertTile extends StatelessWidget {
  final Map<String, dynamic> alert;
  final VoidCallback onTap;

  const _AlertTile({required this.alert, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.add_alert_outlined, size: 25, color: Colors.grey),
          if (!alert['read'])
            const Positioned(
              top: 4,
              right: 0,
              child: CircleAvatar(
                backgroundColor: Colors.red,
                radius: 5,
              ),
            ),
        ],
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
