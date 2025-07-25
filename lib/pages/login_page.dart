import 'package:flutter/material.dart';
import '../main.dart';
import 'signup_page.dart';

// LoginPage widget for user authentication
// Allows user to enter their username and password
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _handleLogin() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    // Validate user credentials
    if (username == 'Martin' && password == '123') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid username or password'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Build the login page UI (user, password fields, buttons)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 53, 52, 52),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.network(
                  'https://images.squarespace-cdn.com/content/v1/67fa8c0fe003dd6c78c62313/da9f915c-8ad6-4e53-93b4-8ac733863bcf/Artboard+1survei%402x.png?format=1500w',
                  height: 120,
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Sign In',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              _buildLabel('User Name:'),
              const SizedBox(height: 4),
              _buildTextField(_usernameController),

              const SizedBox(height: 16),

              _buildLabel('Password:'),
              const SizedBox(height: 4),
              _buildTextField(_passwordController, obscure: true),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildSmallButton('Sign In', _handleLogin),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildSmallButton('Sign Up', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpPage()),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    );
  }

  // Helper method
  Widget _buildTextField(TextEditingController controller, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[800],
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Helper method
  Widget _buildSmallButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: 100,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
