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
      'read': false,
    },
    {
      'title': 'System Update Notice',
      'date': DateTime(2022, 12, 8),
      'preview': 'A new system update is available.',
      'read': false,
    },
    {
      'title': 'Tesla Annual Report',
      'date': DateTime(2022, 12, 5),
      'preview': 'View the new 2022 Tesla performance data.',
      'read': false,
    },
  ];

  List<Map<String, dynamic>> filteredAlerts = [];
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    filteredAlerts = List.from(allAlerts);
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

  void _openDetail(int index) {
    setState(() {
      filteredAlerts[index] = {...filteredAlerts[index], 'read': true};
      selectedIndex = index;
    });
  }

  void _goBack() {
    setState(() {
      selectedIndex = null;
    });
  }

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
          'read': true
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
          'read': true
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (selectedIndex != null) {
      return MessageDetailPage(
        alerts: filteredAlerts,
        currentIndex: selectedIndex!,
        onBack: _goBack,
        onMarkAsUnread: () => _markAsUnread(selectedIndex!),
        onNext: _goToNextAlert,
        onPrevious: _goToPreviousAlert,
      );
    }

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
                  leading: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.electric_car, size: 32),
                      if (!alert['read'])
                        Positioned(
                          top: 4,
                          right: 0,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(alert['title']),
                  subtitle: Text(alert['preview']),
                  trailing: Text(
                    '${alert['date'].month}/${alert['date'].day}/${alert['date'].year}',
                  ),
                  onTap: () => _openDetail(index),
                );
              },
            ),
    );
  }
}
