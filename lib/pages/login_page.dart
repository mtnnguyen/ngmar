import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'graphql_service.dart';
import 'alerts_page.dart';

/// A page that allows users to sign in to the application.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _siteController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  final GraphQLService _service = GraphQLService();

  int _latestPartyId = 0;
  String _latestFullName = 'User';
  String _latestEmail = 'no-email@domain.com';

  int _extractPartyId(dynamic data) {
    final candidates = [
      data?['party_id'],
      data?['partyId'],
      data?['party']?['party_id'],
      data?['party']?['partyId'],
      data?['user']?['party_id'],
      data?['user']?['partyId'],
      data?['data']?['party_id'],
      data?['data']?['partyId'],
    ];
    for (final v in candidates) {
      if (v == null) continue;
      if (v is int) return v;
      final parsed = int.tryParse(v.toString());
      if (parsed != null) return parsed;
    }
    throw StateError('partyId not found in sign-in response');
  }

  Map<String, String> _extractUserInfo(dynamic user) {
    final fullName = user['full_name'] ??
        user['name'] ??
        user['user_name'] ??
        '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();

    final email = user['email'] ?? '';

    return {
      'fullName': fullName.isNotEmpty ? fullName : 'User',
      'email': email.isNotEmpty ? email : 'no-email@domain.com',
    };
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final siteName = _siteController.text.trim().isNotEmpty
        ? _siteController.text.trim()
        : 'TEST_SITE';

    try {
      final data = await _service.signin(username, password, siteName);

      if (data == null) {
        setState(() {
          _errorMessage = 'Something went wrong. Please try again.';
        });
        return;
      }

      if (data['error_code'] == null) {
        final partyId = _extractPartyId(data);
        final user = data['party'] ?? data['user'] ?? {};
        final userInfo = _extractUserInfo(user);
        final fullName = userInfo['fullName']!;
        final email = userInfo['email']!;

        debugPrint(
            'Signed in as: $fullName <$email> | partyId=$partyId | site=$siteName');

        _latestPartyId = partyId;
        _latestFullName = fullName;
        _latestEmail = email;

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AlertsPage(
              partyId: partyId,
              username: username,
              password: password,
              siteName: siteName,
              fullName: fullName,
              email: email,
            ),
          ),
        );
      } else {
        setState(() {
          _errorMessage = "Login failed. Error code: \${data['error_code']}";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Sign-in failed: \$e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text(
          'Sign In',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E1E1E),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 1,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/logo.png', height: 100),
                      const SizedBox(height: 40),
                      _buildInputField('Site', _siteController),
                      _buildInputField('User name', _usernameController),
                      _buildInputField('Password', _passwordController,
                          obscure: true),
                      const SizedBox(height: 24),
                      if (_errorMessage != null)
                        Column(
                          children: [
                            Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.redAccent),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : const Text('Sign In',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14),
                          children: [
                            const TextSpan(text: "Don't have an account? "),
                            TextSpan(
                              text: 'Sign Up',
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () =>
                                    Navigator.pushNamed(context, '/signup'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  const Divider(color: Colors.white30),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style:
                          const TextStyle(color: Colors.white60, fontSize: 12),
                      children: [
                        TextSpan(
                          text: 'Privacy',
                          style: const TextStyle(
                              decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              final username = _usernameController.text.trim();
                              final password = _passwordController.text.trim();
                              final siteName = _siteController.text.trim().isNotEmpty
                                  ? _siteController.text.trim()
                                  : 'TEST_SITE';
                              Navigator.pushNamed(
                                context,
                                '/privacy',
                                arguments: {
                                  'username': username,
                                  'password': password,
                                  'siteName': siteName,
                                  'partyId': _latestPartyId,
                                  'fullName': _latestFullName,
                                  'email': _latestEmail,
                                },
                              );
                            },
                        ),
                        const TextSpan(text: '   •   '),
                        TextSpan(
                          text: 'Legal',
                          style: const TextStyle(
                              decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              final username = _usernameController.text.trim();
                              final password = _passwordController.text.trim();
                              final siteName = _siteController.text.trim().isNotEmpty
                                  ? _siteController.text.trim()
                                  : 'TEST_SITE';
                              Navigator.pushNamed(
                                context,
                                '/legal',
                                arguments: {
                                  'username': username,
                                  'password': password,
                                  'siteName': siteName,
                                  'partyId': _latestPartyId,
                                  'fullName': _latestFullName,
                                  'email': _latestEmail,
                                },
                              );
                            },
                        ),
                        const TextSpan(text: '   •   '),
                        TextSpan(
                          text: 'Acknowledgements',
                          style: const TextStyle(
                              decoration: TextDecoration.underline),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              final username = _usernameController.text.trim();
                              final password = _passwordController.text.trim();
                              final siteName = _siteController.text.trim().isNotEmpty
                                  ? _siteController.text.trim()
                                  : 'TEST_SITE';
                              Navigator.pushNamed(
                                context,
                                '/acknowledgements',
                                arguments: {
                                  'username': username,
                                  'password': password,
                                  'siteName': siteName,
                                  'partyId': _latestPartyId,
                                  'fullName': _latestFullName,
                                  'email': _latestEmail,
                                },
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {bool obscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      );

  InputDecoration _inputDecoration() {
    return const InputDecoration(
      filled: true,
      fillColor: Colors.grey,
      contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide.none,
      ),
    );
  }
}
