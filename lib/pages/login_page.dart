import 'package:flutter/material.dart';
import 'graphql_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  // This widget is the login page application.
  @override
  _LoginPageState createState() => _LoginPageState();
}

// This is the state for the login page.
class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  // This boolean of sign-in button.
  bool _isLoading = false;
  String? _errorMessage;

  // This method is called when the sign-in button is pressed.
  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Validate input
    try {
      final service = GraphQLService();

      final data = await service.signin(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
        'test_site', // This should match your cURL example
      );

      // Check if data is null or contains an error code
      if (data == null) {
        setState(() {
          _errorMessage = 'Something went wrong. Please try again.';
        });
      } else if (data['error_code'] == null && data['party'] != null) {
        final user = data['party'];
        debugPrint('Signed in as: ${user['user_name']} (${user['email']})');
        Navigator.pushReplacementNamed(context, '/menu');
      } else {
        setState(() {
          _errorMessage = "Login failed. Error code: ${data['error_code']}";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Something went wrong. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // This method builds the UI for the login page.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        automaticallyImplyLeading: false, // ✅ ensures no back button is shown
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/surveil_logo.jpeg',
                    height: 100,
                  ),
      const SizedBox(height: 20),
      const Text(
        'Sign In',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  ),
),

              // This is the title of the login page.
              const SizedBox(height: 30),
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
              // This is the sign-in button.
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
                  // This is the text inside the sign-in button.
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Sign In', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              // This is the sign-up button.
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: const Text(
                    "Don't have an account? Sign Up",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // This method builds an input field with a label.
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

  // This method builds a label for the input field.
  Widget _buildLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      );

  // This method builds the input decoration for the text fields.
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
