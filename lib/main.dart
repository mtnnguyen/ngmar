import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'pages/alerts_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'widgets/bottom_nav_bar.dart';

const darkBackground = Color(0xFF121212);

// GraphQL client setup
final HttpLink httpLink = HttpLink(
  'https://kf6iirlcgrbqdmr2b6nq5s6g3q.appsync-api.ca-central-1.amazonaws.com/graphql',
  defaultHeaders: {
    'x-api-key': 'da2-gyewjbxhlvdarogtzp5mbyrm6m',
  },
);

// Initialize the GraphQL client
final ValueNotifier<GraphQLClient> client = ValueNotifier(
  GraphQLClient(
    link: httpLink,
    cache: GraphQLCache(store: InMemoryStore()),
  ),
);

// Main entry point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter(); // Required for caching if needed
  runApp(const InboxApp());
}

// Main application widget
class InboxApp extends StatelessWidget {
  const InboxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginPage(),
          '/signup': (context) => const SignUpPage(),
          '/menu': (context) => const HomePage(),
        },
      ),
    );
  }
}

// Home page with only AlertsPage centered in navigation
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const AlertsPage(), // Only tab
  ];

  void _onItemTapped(int index) {
    if (index >= 0 && index < _pages.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
