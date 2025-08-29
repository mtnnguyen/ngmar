import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'pages/alerts_page.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'widgets/bottom_nav_bar.dart';

const darkBackground = Color(0xFF121212);

final HttpLink httpLink = HttpLink(
  'https://kf6iirlcgrbqdmr2b6nq5s6g3q.appsync-api.ca-central-1.amazonaws.com/graphql',
  defaultHeaders: {'x-api-key': 'da2-gyewjbxhlvdarogtzp5mbyrm6m'},
);

final ValueNotifier<GraphQLClient> client = ValueNotifier(
  GraphQLClient(
    link: httpLink,
    cache: GraphQLCache(store: InMemoryStore()),
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();
  runApp(const InboxApp());
}

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
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/home') {
            final args = settings.arguments;
            if (args is Map<String, dynamic>) {
              return MaterialPageRoute(
                builder: (_) => HomePage(
                  username: args['username'],
                  password: args['password'],
                  siteName: args['siteName'],
                  partyId: args['partyId'],
                  fullName: args['fullName'] ?? args['username'],
                  email: args['email'] ?? '',
                ),
              );
            }
          }
          return null;
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String username;
  final String password;
  final String siteName;
  final int partyId;
  final String fullName;
  final String email;

  const HomePage({
    super.key,
    required this.username,
    required this.password,
    required this.siteName,
    required this.partyId,
    required this.fullName,
    required this.email,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      AlertsPage(
        partyId: widget.partyId,
        username: widget.username,
        password: widget.password,
        siteName: widget.siteName,
        fullName: widget.fullName,
        email: widget.email,
      ),
    ];
  }

  void _onItemTapped(int index) {
    if (index >= 0 && index < _pages.length) {
      setState(() => _selectedIndex = index);
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
