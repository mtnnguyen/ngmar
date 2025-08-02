import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'pages/alerts_page.dart';
import 'pages/actions_page.dart';
import 'pages/events_page.dart';
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

// Initialize Hive for caching if needed
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter(); // Required for caching if you use it
  runApp(const InboxApp());
}

// InboxApp is the main application widget
class InboxApp extends StatelessWidget {
  const InboxApp({super.key});

  // This widget is the root of the application.
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

// HomePage is the main page with a bottom navigation bar
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  // This widget is the root of the HomePage.
  @override
  State<HomePage> createState() => _HomePageState();
}

// _HomePageState is the state for HomePage
class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // List of pages for the bottom navigation bar
  final List<Widget> _pages = const [
    AlertsPage(),
    ActionsPage(),
    EventsPage(),
  ];

  // Handle bottom navigation bar item taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Build the UI for the HomePage
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
