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

/// State for the LoginPage that handles user input and authentication.
class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  final GraphQLService _service = GraphQLService();

  /// Robustly extract partyId from various possible API shapes.
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

  /// Signs in the user with the provided username and password.
  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    const siteName = 'TEST_SITE';

    try {
      final data = await _service.signin(username, password, siteName);

      if (data == null) {
        setState(() {
          _errorMessage = 'Something went wrong. Please try again.';
        });
        return;
      }

      if (data['error_code'] == null && (data['party'] != null || true)) {
        final partyId = _extractPartyId(data);
        final user = data['party'] ?? data['user'] ?? {};

        debugPrint('Signed in as: ${user['user_name'] ?? 'unknown'} (${user['email'] ?? 'no email'}) | partyId=$partyId');

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AlertsPage(
              partyId: partyId,
              username: username,
              password: password,
              siteName: siteName,
            ),
          ),
        );
      } else {
        setState(() {
          _errorMessage = "Login failed. Error code: ${data['error_code']}";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Sign-in failed: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Builds the login page UI.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text(
          'Sign In',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'lib/images/logo.png',
                        height: 100,
                      ),
                      const SizedBox(height: 40),
                      _buildInputField('User name', _usernameController),
                      _buildInputField('Password', _passwordController, obscure: true),
                      const SizedBox(height: 24),
                      if (_errorMessage != null) ...[
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.redAccent),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                      ],
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
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
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
                                ..onTap = () {
                                  Navigator.pushNamed(context, '/signup');
                                },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer section
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: const [
                  Divider(color: Colors.white30),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Privacy', style: TextStyle(color: Colors.white60, fontSize: 12)),
                      SizedBox(width: 16),
                      Text('Legal', style: TextStyle(color: Colors.white60, fontSize: 12)),
                      SizedBox(width: 16),
                      Text('Acknowledgements', style: TextStyle(color: Colors.white60, fontSize: 12)),
                    ],
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a text input field with a label.
  Widget _buildInputField(String label, TextEditingController controller, {bool obscure = false}) {
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

  /// Builds a label for the input fields.
  Widget _buildLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      );

  /// Returns the decoration for the input fields.
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
