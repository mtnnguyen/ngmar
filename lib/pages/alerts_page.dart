import 'package:flutter/material.dart';
import 'detail_pages/message_detail_page.dart';

const darkBackground = Color(0xFF121212);

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  final List<Map<String, dynamic>> allAlerts = [
    {
      'title': 'Welcome to New Inbox',
      'date': DateTime(2022, 12, 7),
      'preview': 'Check your inbox for important info...',
    },
    {
      'title': 'System Update Notice',
      'date': DateTime(2022, 12, 8),
      'preview': 'A new system update is available.',
    },
    {
      'title': 'Tesla Annual Report',
      'date': DateTime(2022, 12, 5),
      'preview': 'View the new 2022 Tesla performance data.',
    },
  ];

  List<Map<String, dynamic>> filteredAlerts = [];

  @override
  void initState() {
    super.initState();
    filteredAlerts = List.from(allAlerts); // make a copy
  }

  void _sortAlerts(String order) {
    setState(() {
      if (order == 'newest') {
        filteredAlerts.sort((a, b) => b['date'].compareTo(a['date']));
      } else if (order == 'oldest') {
        filteredAlerts.sort((a, b) => a['date'].compareTo(b['date']));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Alerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
              final selected = await showMenu<String>(
                context: context,
                position: RelativeRect.fromLTRB(1000, 80, 10, 100),
                items: [
                  const PopupMenuItem(
                      value: 'newest', child: Text('Newest to Oldest')),
                  const PopupMenuItem(
                      value: 'oldest', child: Text('Oldest to Newest')),
                ],
              );
              if (selected != null) _sortAlerts(selected);
            },
            tooltip: 'Sort Alerts',
          ),
        ],
      ),
      body: filteredAlerts.isEmpty
          ? const Center(child: Text('No alerts found.'))
          : ListView.builder(
              itemCount: filteredAlerts.length,
              itemBuilder: (context, index) {
                final alert = filteredAlerts[index];
                return ListTile(
                  leading: const Icon(Icons.electric_car, size: 32),
                  title: Text(alert['title']),
                  subtitle: Text(alert['preview']),
                  trailing: Text(
                    '${alert['date'].month}/${alert['date'].day}/${alert['date'].year}',
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MessageDetailPage(
                          alerts: filteredAlerts,
                          currentIndex: index,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
